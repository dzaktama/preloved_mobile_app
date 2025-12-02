// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ApiService {
  // Base URL API (updated to new service)
  static const String baseUrl = 'https://preloved-data-api.vercel.app';

  // Common endpoints (following the provided API)
  // Auth endpoints (register/login/me/updateprofile/updatepassword)
  static const String authEndpoint = '/api/auth';
  // Products endpoints
  static const String productsEndpoint = '/api/products';
  // Address endpoint (if still used elsewhere)
  static const String alamatEndpoint = '/api/alamat';

  // ==================== GET ALL PRODUCTS ====================
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$productsEndpoint'), headers: {
        'Content-Type': 'application/json',
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List<ProductModel> products = [];

        // Support API returning either a raw array or an object with a data field
        if (decoded is List) {
          products = decoded.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
        } else if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data')) {
            final list = decoded['data'];
            if (list is List) {
              products = list.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
            }
          } else if (decoded.containsKey('data_barang')) {
            final list = decoded['data_barang'];
            if (list is List) {
              products = list.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
            }
          }
        }

        return {
          'success': true,
          'message': 'Products loaded successfully',
          'data': products,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Products not found',
          'data': <ProductModel>[],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load products. Status code: ${response.statusCode}',
          'data': <ProductModel>[],
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
        'data': <ProductModel>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'data': <ProductModel>[],
      };
    }
  }

  // ==================== AUTH / USERS ====================
  // Register user: POST /api/auth/register
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$authEndpoint/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      final decoded = _tryDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User created',
          'statusCode': response.statusCode,
          'data': decoded,
          'raw': response.body,
        };
      }

      return {
        'success': false,
        'message': 'Failed to create user',
        'statusCode': response.statusCode,
        'data': decoded,
        'raw': response.body,
      };
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  // Login user: POST /api/auth/login
  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$authEndpoint/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      final decoded = _tryDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Login successful',
          'statusCode': response.statusCode,
          'data': decoded,
          'raw': response.body,
        };
      }

      return {
        'success': false,
        'message': 'Login failed',
        'statusCode': response.statusCode,
        'data': decoded,
        'raw': response.body,
      };
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  dynamic _tryDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  // Get profile (private): GET /api/auth/me
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$authEndpoint/me'), headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Profile loaded', 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to load profile', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  // Update profile (private): PUT /api/auth/updateprofile
  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> body) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl$authEndpoint/updateprofile'), headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }, body: json.encode(body)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Profile updated', 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update profile', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  // Update password (private): PUT /api/auth/updatepassword
  Future<Map<String, dynamic>> updatePassword(String token, Map<String, dynamic> body) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl$authEndpoint/updatepassword'), headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }, body: json.encode(body)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password updated', 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update password', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  // ==================== BARANG (PRODUCT) ====================
  Future<Map<String, dynamic>> getBarangs() async {
    return await getAllProducts();
  }

  Future<Map<String, dynamic>> getBarangById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$productsEndpoint/$id'), headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'message': 'Barang loaded', 'data': ProductModel.fromJson(decoded)};
      }

      return {'success': false, 'message': 'Barang not found', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> createBarang(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$productsEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Barang created', 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to create barang', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> updateBarang(String id, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$productsEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Barang updated', 'data': json.decode(response.body)};
      }

      return {'success': false, 'message': 'Failed to update barang', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> deleteBarang(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$productsEndpoint/$id')).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Barang deleted', 'data': null};
      }

      return {'success': false, 'message': 'Failed to delete barang', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  // ==================== ALAMAT ====================
  Future<Map<String, dynamic>> getAlamat() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$alamatEndpoint'), headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Alamat loaded', 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to load alamat', 'data': []};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': []};
    }
  }

  Future<Map<String, dynamic>> updateAlamat(String id, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$alamatEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Alamat updated', 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update alamat', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> deleteAlamat(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$alamatEndpoint/$id')).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Alamat deleted', 'data': null};
      }
      return {'success': false, 'message': 'Failed to delete alamat', 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': null};
    }
  }

  // ==================== SEARCH PRODUCTS ====================
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> allProducts = result['data'];
        
        // Filter products based on query
        List<ProductModel> filteredProducts = allProducts.where((product) {
          final namaBarang = product.namaBarang.toLowerCase();
          final brand = product.brand.toLowerCase();
          final kategori = product.kategori.toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return namaBarang.contains(searchQuery) ||
                 brand.contains(searchQuery) ||
                 kategori.contains(searchQuery);
        }).toList();

        return {
          'success': true,
          'message': 'Search completed',
          'data': filteredProducts,
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Search failed: $e',
        'data': <ProductModel>[],
      };
    }
  }

  // ==================== FILTER BY CATEGORY ====================
  Future<Map<String, dynamic>> filterByCategory(String category) async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> allProducts = result['data'];
        
        // Filter by category
        List<ProductModel> filteredProducts = allProducts.where((product) {
          return product.kategori.toLowerCase() == category.toLowerCase();
        }).toList();

        return {
          'success': true,
          'message': 'Filter completed',
          'data': filteredProducts,
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Filter failed: $e',
        'data': <ProductModel>[],
      };
    }
  }

  // ==================== SORT PRODUCTS ====================
  List<ProductModel> sortProducts(
    List<ProductModel> products,
    String sortBy,
  ) {
    List<ProductModel> sortedProducts = List.from(products);

    switch (sortBy) {
      case 'price_low_to_high':
        sortedProducts.sort((a, b) => a.hargaInt.compareTo(b.hargaInt));
        break;
      case 'price_high_to_low':
        sortedProducts.sort((a, b) => b.hargaInt.compareTo(a.hargaInt));
        break;
      case 'name_a_to_z':
        sortedProducts.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
        break;
      case 'name_z_to_a':
        sortedProducts.sort((a, b) => b.namaBarang.compareTo(a.namaBarang));
        break;
      case 'brand':
        sortedProducts.sort((a, b) => a.brand.compareTo(b.brand));
        break;
      default:
        // No sorting
        break;
    }

    return sortedProducts;
  }

  // ==================== GET UNIQUE CATEGORIES ====================
  Future<List<String>> getCategories() async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> products = result['data'];
        Set<String> categories = products.map((p) => p.kategori).toSet();
        return categories.toList()..sort();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==================== GET UNIQUE BRANDS ====================
  Future<List<String>> getBrands() async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> products = result['data'];
        Set<String> brands = products.map((p) => p.brand).toSet();
        return brands.toList()..sort();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}