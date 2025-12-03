import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/barang_model.dart';
import '../services/database_helper.dart';
import '../services/layanan_api.dart';
import '../controller/auth_controller.dart';

class ControllerBarang {
  final ImagePicker _picker = ImagePicker();
  final dbHelper = DatabaseHelper.instance;
  final ApiService _api = ApiService();
  final AuthController _authController = AuthController();

  // ==================== IMAGE HANDLING ====================
  
  /// Ambil foto dari kamera
  Future<String?> ambilFotoDariKamera() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (foto != null) {
        return await _simpanFotoLokal(foto);
      }
      return null;
    } catch (e) {
      print('Error ambilFotoDariKamera: $e');
      return null;
    }
  }

  /// Ambil foto dari galeri
  Future<String?> ambilFotoDariGaleri() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (foto != null) {
        return await _simpanFotoLokal(foto);
      }
      return null;
    } catch (e) {
      print('Error ambilFotoDariGaleri: $e');
      return null;
    }
  }

  /// Simpan foto ke storage lokal
  Future<String> _simpanFotoLokal(XFile foto) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(foto.path)}';
    final String pathBaru = path.join(appDir.path, 'foto_barang', fileName);

    // Buat folder jika belum ada
    final Directory folderFoto = Directory(path.dirname(pathBaru));
    if (!await folderFoto.exists()) {
      await folderFoto.create(recursive: true);
    }

    // Copy file ke storage app
    final File fileBaru = await File(foto.path).copy(pathBaru);
    return fileBaru.path;
  }

  /// Convert image to Base64 untuk upload ke API
  Future<String?> _imageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        print('❌ Image file not found: $imagePath');
        return null;
      }
      
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Detect image type
      String imageType = 'jpeg';
      if (imagePath.toLowerCase().endsWith('.png')) {
        imageType = 'png';
      } else if (imagePath.toLowerCase().endsWith('.jpg') || imagePath.toLowerCase().endsWith('.jpeg')) {
        imageType = 'jpeg';
      }
      
      return 'data:image/$imageType;base64,$base64String';
    } catch (e) {
      print('❌ Error converting image to base64: $e');
      return null;
    }
  }

  // ==================== CREATE PRODUCT ====================
  
  /// Tambah barang baru (POST /api/products)
  /// Simpan ke API dulu, jika berhasil simpan ke local database
  Future<bool> tambahBarang(BarangJualanModel barang) async {
    try {
      print('═══════════════════════════════════════');
      print('🔵 TAMBAH BARANG - START');
      
      // Get token
      final token = await _authController.getToken();
      
      if (token.isEmpty) {
        print('⚠️ No token found, saving locally only');
        print('═══════════════════════════════════════');
        return await _simpanBarangLokal(barang);
      }

      print('✅ Token found: ${token.substring(0, 20)}...');

      // Convert image to base64
      String? base64Image;
      if (barang.pathGambar.isNotEmpty) {
        print('🔄 Converting image to base64...');
        base64Image = await _imageToBase64(barang.pathGambar);
        if (base64Image == null) {
          print('❌ Failed to convert image');
          return false;
        }
        print('✅ Image converted (${base64Image.length} chars)');
      } else {
        print('⚠️ No image path provided');
      }

      // Prepare data untuk API dengan field name yang SESUAI
      final productData = {
        'namaBarang': barang.namaBarang.trim(),
        'harga': barang.harga.replaceAll(RegExp(r'[^0-9]'), ''), // Angka saja
        'kategori': barang.kategori,
        'kondisi': barang.kondisi,
        'ukuran': barang.ukuran,
        'brand': barang.brand.trim(),
        'bahan': barang.bahan.trim(),
        'deskripsi': barang.deskripsi.trim(),
        'lokasi': barang.lokasi.trim(),
        'kontakPenjual': barang.kontakPenjual.trim(),
        'gambar_barang': base64Image ?? '', // Base64 string
      };

      print('📦 Product data prepared:');
      print('   - namaBarang: ${productData['namaBarang']}');
      print('   - harga: ${productData['harga']}');
      print('   - kategori: ${productData['kategori']}');
      print('   - brand: ${productData['brand']}');
      print('   - gambar length: ${(base64Image ?? '').length}');

      // Upload ke API
      print('📤 Sending to API...');
      final response = await _api.createProduct(token, productData);

      print('📥 API Response:');
      print('   - success: ${response['success']}');
      print('   - message: ${response['message']}');
      
      if (response['success']) {
        print('✅ Product created via API');
        
        // Simpan juga ke local database dengan data dari API
        try {
          final apiData = response['data'];
          print('📦 API returned data: $apiData');
          
          if (apiData != null) {
            // Parse response dari API
            final barangWithApiData = barang.copy(
              id: _parseId(apiData['_id'] ?? apiData['id']),
              userId: apiData['userId']?.toString(),
              gambarUrl: apiData['gambar_barang'],
              tanggalUpload: apiData['createdAt'] ?? DateTime.now().toIso8601String(),
            );
            await _simpanBarangLokal(barangWithApiData);
            print('✅ Also saved to local database');
          } else {
            await _simpanBarangLokal(barang);
            print('✅ Saved to local database (no API data)');
          }
        } catch (e) {
          print('⚠️ Failed to save locally: $e');
        }
        
        print('═══════════════════════════════════════');
        return true;
      } else {
        print('❌ API failed: ${response['message']}');
        print('📦 Full response: ${response}');
        print('⚠️ Saving locally as fallback');
        print('═══════════════════════════════════════');
        return await _simpanBarangLokal(barang);
      }
    } catch (e, stackTrace) {
      print('❌ Error tambahBarang: $e');
      print('Stack trace: $stackTrace');
      print('⚠️ Fallback to local save');
      print('═══════════════════════════════════════');
      return await _simpanBarangLokal(barang);
    }
  }

  /// Helper untuk parse ID (bisa int atau string dari MongoDB)
  int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      // Jika MongoDB ObjectId, gunakan hashCode
      if (value.length == 24) {
        return value.hashCode;
      }
      return int.tryParse(value);
    }
    return null;
  }

  /// Simpan barang ke database lokal saja
  Future<bool> _simpanBarangLokal(BarangJualanModel barang) async {
    try {
      final db = await dbHelper.database;
      await db.insert('barang_jualan', barang.toMap());
      print('✅ Product saved locally');
      return true;
    } catch (e) {
      print('❌ Error _simpanBarangLokal: $e');
      return false;
    }
  }

  // ==================== GET PRODUCTS ====================
  
  /// Ambil barang user dari API (GET /api/products/my/products)
  Future<List<BarangJualanModel>> ambilBarangUser(int userId) async {
    try {
      final token = await _authController.getToken();
      
      if (token.isEmpty) {
        print('⚠️ No token, loading from local database');
        return await _ambilBarangUserLokal(userId);
      }

      // Get from API
      print('📤 Getting my products from API...');
      final response = await _api.getMyProducts(token);

      if (response['success']) {
        // Convert ProductModel list to BarangJualanModel list
        List<dynamic> apiProducts = response['data'];
        List<BarangJualanModel> products = apiProducts.map((product) {
          if (product is BarangJualanModel) {
            return product;
          }
          // Jika ProductModel, convert ke BarangJualanModel
          return BarangJualanModel.fromJson(product.toJson());
        }).toList();
        
        print('✅ Loaded ${products.length} products from API');
        
        // Sync ke local database
        await _syncProductsToLocal(products);
        
        return products;
      } else {
        print('⚠️ API failed, loading from local');
        return await _ambilBarangUserLokal(userId);
      }
    } catch (e) {
      print('❌ Error ambilBarangUser: $e');
      return await _ambilBarangUserLokal(userId);
    }
  }

  /// Ambil barang user dari database lokal
  Future<List<BarangJualanModel>> _ambilBarangUserLokal(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'barang_jualan',
        where: 'id_penjual = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_upload DESC',
      );

      return List.generate(maps.length, (i) {
        return BarangJualanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('❌ Error _ambilBarangUserLokal: $e');
      return [];
    }
  }

  /// Ambil semua barang (GET /api/products)
  Future<List<BarangJualanModel>> ambilSemuaBarang() async {
    try {
      print('📤 Getting all products from API...');
      final response = await _api.getAllProducts();

      if (response['success']) {
        // Convert ProductModel list to BarangJualanModel list
        List<dynamic> apiProducts = response['data'];
        List<BarangJualanModel> products = apiProducts.map((product) {
          if (product is BarangJualanModel) {
            return product;
          }
          // Jika ProductModel, convert ke BarangJualanModel
          return BarangJualanModel.fromJson(product.toJson());
        }).toList();
        
        print('✅ Loaded ${products.length} products from API');
        
        // Sync ke local database
        await _syncProductsToLocal(products);
        
        return products;
      } else {
        print('⚠️ API failed, loading from local');
        return await _ambilSemuaBarangLokal();
      }
    } catch (e) {
      print('❌ Error ambilSemuaBarang: $e');
      return await _ambilSemuaBarangLokal();
    }
  }

  /// Ambil semua barang dari database lokal
  Future<List<BarangJualanModel>> _ambilSemuaBarangLokal() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'barang_jualan',
        orderBy: 'tanggal_upload DESC',
      );

      return List.generate(maps.length, (i) {
        return BarangJualanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('❌ Error _ambilSemuaBarangLokal: $e');
      return [];
    }
  }

  /// Sync products dari API ke local database
  Future<void> _syncProductsToLocal(List<BarangJualanModel> products) async {
    try {
      final db = await dbHelper.database;
      
      for (var product in products) {
        if (product.id == null) continue;
        
        // Cek apakah product sudah ada
        final existing = await db.query(
          'barang_jualan',
          where: 'id = ?',
          whereArgs: [product.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          await db.insert('barang_jualan', product.toMap());
        } else {
          await db.update(
            'barang_jualan',
            product.toMap(),
            where: 'id = ?',
            whereArgs: [product.id],
          );
        }
      }
      print('✅ Synced ${products.length} products to local');
    } catch (e) {
      print('⚠️ Failed to sync to local: $e');
    }
  }

  // ==================== UPDATE PRODUCT ====================
  
  /// Update barang (PUT /api/products/:id)
  Future<bool> updateBarang(BarangJualanModel barang) async {
    try {
      final token = await _authController.getToken();

      if (token.isEmpty || barang.id == null) {
        print('⚠️ No token or ID, updating locally only');
        return await _updateBarangLokal(barang);
      }

      // Convert image if there's a new local path
      String? imageData = barang.gambarUrl;
      if (barang.pathGambar.isNotEmpty && !barang.pathGambar.startsWith('http')) {
        imageData = await _imageToBase64(barang.pathGambar);
      }

      // Prepare data untuk API
      final productData = {
        'namaBarang': barang.namaBarang,
        'harga': barang.harga.replaceAll(RegExp(r'[^0-9]'), ''),
        'kategori': barang.kategori,
        'kondisi': barang.kondisi,
        'ukuran': barang.ukuran,
        'brand': barang.brand,
        'bahan': barang.bahan,
        'deskripsi': barang.deskripsi,
        'lokasi': barang.lokasi,
        'kontakPenjual': barang.kontakPenjual,
        'gambar_barang': imageData ?? '',
      };

      // Update via API
      print('📤 Updating product via API...');
      final response = await _api.updateProduct(
        token,
        barang.id.toString(),
        productData,
      );

      if (response['success']) {
        print('✅ Product updated via API');
        
        // Update juga di local
        await _updateBarangLokal(barang);
        
        return true;
      } else {
        print('⚠️ API failed, updating locally');
        return await _updateBarangLokal(barang);
      }
    } catch (e) {
      print('❌ Error updateBarang: $e');
      return await _updateBarangLokal(barang);
    }
  }

  /// Update barang di database lokal
  Future<bool> _updateBarangLokal(BarangJualanModel barang) async {
    try {
      final db = await dbHelper.database;

      await db.update(
        'barang_jualan',
        barang.toMap(),
        where: 'id = ?',
        whereArgs: [barang.id],
      );

      print('✅ Product updated locally');
      return true;
    } catch (e) {
      print('❌ Error _updateBarangLokal: $e');
      return false;
    }
  }

  // ==================== DELETE PRODUCT ====================
  
  /// Hapus barang (DELETE /api/products/:id)
  Future<bool> hapusBarang(BarangJualanModel barang) async {
    try {
      final token = await _authController.getToken();

      // Hapus foto fisik jika ada
      if (barang.pathGambar.isNotEmpty && await File(barang.pathGambar).exists()) {
        await File(barang.pathGambar).delete();
      }

      if (token.isEmpty || barang.id == null) {
        print('⚠️ No token or ID, deleting locally only');
        return await _hapusBarangLokal(barang);
      }

      // Delete via API
      print('📤 Deleting product via API...');
      final response = await _api.deleteProduct(token, barang.id.toString());

      if (response['success']) {
        print('✅ Product deleted via API');
        
        // Delete juga di local
        await _hapusBarangLokal(barang);
        
        return true;
      } else {
        print('⚠️ API failed, deleting locally');
        return await _hapusBarangLokal(barang);
      }
    } catch (e) {
      print('❌ Error hapusBarang: $e');
      return await _hapusBarangLokal(barang);
    }
  }

  /// Hapus barang dari database lokal
  Future<bool> _hapusBarangLokal(BarangJualanModel barang) async {
    try {
      final db = await dbHelper.database;

      await db.delete(
        'barang_jualan',
        where: 'id = ?',
        whereArgs: [barang.id],
      );

      print('✅ Product deleted locally');
      return true;
    } catch (e) {
      print('❌ Error _hapusBarangLokal: $e');
      return false;
    }
  }

  // ==================== GET PRODUCT BY ID ====================
  
  /// Get single product by ID (GET /api/products/:id)
  Future<BarangJualanModel?> getBarangById(String id) async {
    try {
      print('📤 Getting product $id from API...');
      final response = await _api.getProductById(id);

      if (response['success']) {
        final productData = response['data'];
        if (productData != null) {
          // Convert ProductModel to BarangJualanModel if needed
          if (productData is BarangJualanModel) {
            return productData;
          }
          return BarangJualanModel.fromJson(productData.toJson());
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getBarangById: $e');
      return null;
    }
  }
}