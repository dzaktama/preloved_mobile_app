import 'package:hive_flutter/hive_flutter.dart';
import '../model/userModel.dart';

class AuthController {
  // Register User Baru
  Future<bool> register(UserModel userBaru) async {
    var box = await Hive.openBox<UserModel>('box_user_preloved');
    
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
      
      var sessionBox = await Hive.openBox('box_session');
      await sessionBox.put('is_login', true);
      await sessionBox.put('id_user', userKetemu.key);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Ambil Data User yang Login
  Future<UserModel?> getUserLogin() async {
    var sessionBox = await Hive.openBox('box_session');
    var idUser = sessionBox.get('id_user');
    
    if (idUser == null) return null;
    
    var box = await Hive.openBox<UserModel>('box_user_preloved');
    return box.get(idUser);
  }

  // Update Profil User
  Future<bool> updateProfil(UserModel userUpdate) async {
    try {
      await userUpdate.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cek Status Login
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