import 'package:hive_flutter/hive_flutter.dart';
import '../model/userModel.dart';

class ProfileController {
  // Ambil data user yang sedang login
  Future<UserModel?> getUserLogin() async {
    var sessionBox = await Hive.openBox('box_session');
    var idUser = sessionBox.get('id_user');
    
    if (idUser == null) return null;
    
    var box = await Hive.openBox<UserModel>('box_user_preloved');
    return box.get(idUser);
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
      if (fotoProfilBaru != null) user.uFotoProfil = fotoProfilBaru;

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
}