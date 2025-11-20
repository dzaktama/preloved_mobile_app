import 'package:hive_flutter/hive_flutter.dart';
import '../model/akun_user_model.dart';

class AuthController {
  // Register User Baru
  Future<bool> register(AkunUserModel userBaru) async {
    var box = await Hive.openBox<AkunUserModel>('box_user_preloved');
    
    // Cek apakah email sudah ada
    bool emailAda = box.values.any((user) => user.email == userBaru.email);
    
    if (emailAda) {
      return false;
    } else {
      await box.add(userBaru);
      return true;
    }
  }

  // Login User
  Future<bool> login(String email, String password) async {
    var box = await Hive.openBox<AkunUserModel>('box_user_preloved');

    try {
      var userKetemu = box.values.firstWhere(
        (user) => user.email == email && user.password == password,
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