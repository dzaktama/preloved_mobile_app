import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/userModel.dart';
import '../services/database_helper.dart';
import '../controller/auth_controller.dart';
import '../controller/controller_barang.dart';
import '../controller/controller_address.dart';
import '../controller/controller_transaksi.dart';

class ProfileController {
  final ImagePicker _picker = ImagePicker();
  final dbHelper = DatabaseHelper.instance;
  final authController = AuthController();

  // Ambil foto dari kamera
  Future<String?> ambilFotoDariKamera() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
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

  // Ambil foto dari galeri
  Future<String?> ambilFotoDariGaleri() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
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

  // Simpan foto ke storage lokal
  Future<String> _simpanFotoLokal(XFile foto) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(foto.path)}';
    final String pathBaru = path.join(appDir.path, 'foto_profil', fileName);

    // Buat folder jika belum ada
    final Directory folderFoto = Directory(path.dirname(pathBaru));
    if (!await folderFoto.exists()) {
      await folderFoto.create(recursive: true);
    }

    // Copy file ke storage app
    final File fileBaru = await File(foto.path).copy(pathBaru);
    return fileBaru.path;
  }

  // Update profil user
  Future<bool> updateProfil({
    required UserModel user,
    String? namaBaru,
    String? emailBaru,
    String? nomorHpBaru,
    String? alamatBaru,
    String? fotoProfilBaru,
  }) async {
    try {
      final updatedUser = user.copy(
        uName: namaBaru ?? user.uName,
        uEmail: emailBaru ?? user.uEmail,
        uPhone: nomorHpBaru ?? user.uPhone,
        uAddress: alamatBaru ?? user.uAddress,
        uFotoProfil: fotoProfilBaru ?? user.uFotoProfil,
      );

      return await authController.updateUser(updatedUser);
    } catch (e) {
      print('Error updateProfil: $e');
      return false;
    }
  }

  // Cek apakah email tersedia
  Future<bool> cekEmailTersedia(String emailBaru, String emailLama) async {
    if (emailBaru == emailLama) return true;

    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [emailBaru],
      );

      return result.isEmpty;
    } catch (e) {
      print('Error cekEmailTersedia: $e');
      return false;
    }
  }

  // Ganti password
  Future<bool> gantiPassword({
    required UserModel user,
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      // Verifikasi password lama
      if (user.uPassword != passwordLama) {
        return false;
      }

      final updatedUser = user.copy(uPassword: passwordBaru);
      return await authController.updateUser(updatedUser);
    } catch (e) {
      print('Error gantiPassword: $e');
      return false;
    }
  }

  // Get statistics untuk profile page
  Future<Map<String, int>> getStatistics(int userId) async {
    try {
      final controllerBarang = ControllerBarang();
      final addressController = AddressController();
      final transaksiController = ControllerTransaksi();

      final barang = await controllerBarang.ambilBarangUser(userId);
      final addresses = await addressController.ambilAlamatUser(userId);
      final transaksi = await transaksiController.ambilTransaksiByUser(userId);

      return {
        'items': barang.length,
        'addresses': addresses.length,
        'orders': transaksi.length,
      };
    } catch (e) {
      print('Error getStatistics: $e');
      return {'items': 0, 'addresses': 0, 'orders': 0};
    }
  }
}