import 'package:hive_flutter/hive_flutter.dart';
import '../model/userModel.dart';

class AuthController {
  // Register User Baru
  Future<bool> register(UserModel userBaru) async {
    var box = await Hive.openBox<UserModel>('box_user_preloved');
    
    // Cek apakah email sudah ada
    bool emailAda = box.values.any((user) => user.uEmail == userBaru.uEmail);
    
    if (emailAda) {
      return false;
    } else {
      await box.add(userBaru);
      return true;
    }
  }

  // Login User
  Future<bool> login(String email, String password) async {
    var box = await Hive.openBox<UserModel>('box_user_preloved');

    try {
      var userKetemu = box.values.firstWhere(
        (user) => user.uEmail == email && user.uPassword == password,
      );
      
      // Simpan sesi login
      var sessionBox = await Hive.openBox('box_session');
      await sessionBox.put('is_login', true);
      await sessionBox.put('id_user', userKetemu.key);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // TAMBAHAN: Ambil data user yang sedang login
  Future<UserModel?> getUserLogin() async {
    try {
      var sessionBox = await Hive.openBox('box_session');
      var userId = sessionBox.get('id_user');
      
      if (userId == null) return null;
      
      var box = await Hive.openBox<UserModel>('box_user_preloved');
      return box.get(userId);
    } catch (e) {
      return null;
    }
  }

  // TAMBAHAN: Update data user
  Future<bool> updateUser(UserModel user) async {
    try {
      await user.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cek Status Login (Untuk Splash Screen)
  Future<bool> cekSesi() async {
    var sessionBox = await Hive.openBox('box_session');
    return sessionBox.get('is_login', defaultValue: false);
  }

  // Logout
  Future<void> logout() async {
    var sessionBox = await Hive.openBox('box_session');
    await sessionBox.clear();
  }
}