import '../model/userModel.dart';
import '../services/database_helper.dart';

class AuthController {
  final dbHelper = DatabaseHelper.instance;

  // Register User Baru
  Future<bool> register(UserModel userBaru) async {
    try {
      final db = await dbHelper.database;

      // Cek apakah email sudah ada
      final List<Map<String, dynamic>> existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [userBaru.uEmail],
      );

      if (existingUser.isNotEmpty) {
        return false; // Email sudah terdaftar
      }

      // Insert user baru
      userBaru.createdAt = DateTime.now().toIso8601String();
      await db.insert('users', userBaru.toMap());
      return true;
    } catch (e) {
      print('Error register: $e');
      return false;
    }
  }

  // Login User
  Future<bool> login(String email, String password) async {
    try {
      final db = await dbHelper.database;

      // Cari user dengan email dan password yang sesuai
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (users.isEmpty) {
        return false;
      }

      final user = UserModel.fromMap(users.first);

      // Hapus session lama jika ada
      await db.delete('session');

      // Simpan sesi login baru
      await db.insert('session', {
        'is_login': 1,
        'user_id': user.id,
      });

      return true;
    } catch (e) {
      print('Error login: $e');
      return false;
    }
  }

  // Ambil data user yang sedang login
  Future<UserModel?> getUserLogin() async {
    try {
      final db = await dbHelper.database;

      // Ambil session
      final List<Map<String, dynamic>> sessions = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (sessions.isEmpty) {
        return null;
      }

      final userId = sessions.first['user_id'] as int;

      // Ambil data user
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        return null;
      }

      return UserModel.fromMap(users.first);
    } catch (e) {
      print('Error getUserLogin: $e');
      return null;
    }
  }

  // Update data user
  Future<bool> updateUser(UserModel user) async {
    try {
      final db = await dbHelper.database;

      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );

      return true;
    } catch (e) {
      print('Error updateUser: $e');
      return false;
    }
  }

  // Cek Status Login (Untuk Splash Screen)
  Future<bool> cekSesi() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> sessions = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
      );

      return sessions.isNotEmpty;
    } catch (e) {
      print('Error cekSesi: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final db = await dbHelper.database;
      await db.delete('session');
    } catch (e) {
      print('Error logout: $e');
    }
  }
}