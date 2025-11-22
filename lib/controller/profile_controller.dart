import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/userModel.dart';
import '../model/address_model.dart';

class ProfileController {
  final ImagePicker _picker = ImagePicker();

  // Ambil data user yang sedang login
  Future<UserModel?> getUserLogin() async {
    var sessionBox = await Hive.openBox('box_session');
    var idUser = sessionBox.get('id_user');
    
    if (idUser == null) return null;
    
    var box = await Hive.openBox<UserModel>('box_user_preloved');
    return box.get(idUser);
  }

  // Ambil foto profil dari kamera
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
      return null;
    }
  }

  // Ambil foto profil dari galeri
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
      return null;
    }
  }

  // Simpan foto ke storage lokal
  Future<String> _simpanFotoLokal(XFile foto) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(foto.path)}';
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
      // Update field yang diubah
      if (namaBaru != null) user.uName = namaBaru;
      if (emailBaru != null) user.uEmail = emailBaru;
      if (nomorHpBaru != null) user.uPhone = nomorHpBaru;
      if (alamatBaru != null) user.uAddress = alamatBaru;
      if (fotoProfilBaru != null) {
        // Hapus foto lama jika ada
        if (user.uFotoProfil != null && user.uFotoProfil!.isNotEmpty) {
          try {
            if (await File(user.uFotoProfil!).exists()) {
              await File(user.uFotoProfil!).delete();
            }
          } catch (e) {
            // Ignore error
          }
        }
        user.uFotoProfil = fotoProfilBaru;
      }

      // Simpan ke database
      await user.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cek apakah email sudah dipakai user lain
  Future<bool> cekEmailTersedia(String email, String emailSekarang) async {
    if (email == emailSekarang) return true;
    
    var box = await Hive.openBox<UserModel>('box_user_preloved');
    bool emailAda = box.values.any((user) => user.uEmail == email);
    
    return !emailAda;
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

      // Update password
      user.uPassword = passwordBaru;
      await user.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get statistics
  Future<Map<String, int>> getStatistics(String idUser) async {
    try {
      // Hitung jumlah barang dijual
      var boxBarang = await Hive.openBox('box_barang_jualan');
      int jumlahBarang = boxBarang.values.where((b) => b.idPenjual == idUser).length;

      // Hitung jumlah transaksi
      var boxTransaksi = await Hive.openBox('box_transaksi');
      int jumlahTransaksi = boxTransaksi.values.where((t) => t.idUser == idUser).length;

      // Hitung jumlah alamat
      var boxAddress = await Hive.openBox<AddressModel>('box_address');
      int jumlahAlamat = boxAddress.values.where((a) => a.idUser == idUser).length;

      return {
        'items': jumlahBarang,
        'orders': jumlahTransaksi,
        'addresses': jumlahAlamat,
      };
    } catch (e) {
      return {
        'items': 0,
        'orders': 0,
        'addresses': 0,
      };
    }
  }
}