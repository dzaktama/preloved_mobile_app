import '../model/userModel.dart';
import '../services/database_helper.dart';
import '../services/layanan_api.dart';
import 'dart:convert';

class AuthController {
  final dbHelper = DatabaseHelper.instance;
  final ApiService _api = ApiService();

  // Register User Baru
  // Register User Baru (calls API, then stores local copy)
  Future<bool> register(UserModel userBaru) async {
    try {
      final body = {
        'name': userBaru.uName ?? '',
        'email': userBaru.uEmail ?? '',
        'password': userBaru.uPassword ?? '',
      };
      // Logging request
      print('AuthController.register -> request body: ${json.encode(body)}');
      final res = await _api.registerUser(body);
      // Log full response for debugging
      print('AuthController.register -> API response: $res');
      if (res['success']) {
        // If API returns user data, save locally (optional)
        final data = res['data'];
        try {
          final db = await dbHelper.database;
          final userMap = <String, dynamic>{
            'name': data['name'] ?? userBaru.uName,
            'email': data['email'] ?? userBaru.uEmail,
            'password': userBaru.uPassword,
            'phone': data['phone'] ?? '',
            'address': data['address'] ?? '',
            'foto_profil': data['foto_profil'] ?? '',
            'role': data['role'] ?? 'user',
            'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
          };

          await db.insert('users', userMap);
        } catch (e) {
          // local insert failure shouldn't break registration
          print('Warning: failed to save user locally: $e');
        }

        return true;
      }

      // If API replied with failure, log details
      print('AuthController.register -> registration failed: ${res['message']} status:${res['statusCode'] ?? 'n/a'} raw:${res['raw'] ?? ''}');
      return false;
    } catch (e) {
      print('Error register: $e');
      return false;
    }
  }

  // Login User
  // Login via API, store token and user locally
  Future<bool> login(String email, String password) async {
    try {
      final body = {'email': email, 'password': password};
      // Logging request
      print('AuthController.login -> request body: ${json.encode(body)}');
      final res = await _api.loginUser(body);
      print('AuthController.login -> API response: $res');
      if (!(res['success'] == true)) {
        print('AuthController.login -> login failed: ${res['message']} status:${res['statusCode'] ?? 'n/a'} raw:${res['raw'] ?? ''}');
        return false;
      }

      final data = res['data'];

      // Try to extract token and user
      String token = '';
      Map<String, dynamic>? userData;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('token')) token = data['token'] ?? '';
        if (data.containsKey('accessToken')) token = data['accessToken'] ?? token;
        if (data.containsKey('user')) userData = data['user'];
        // Some APIs return user directly
        if (userData == null && data.containsKey('data')) {
          final d = data['data'];
          if (d is Map<String, dynamic>) userData = d;
        }
      }

      // If no explicit user, fallback to minimal mapping
      userData ??= {'name': '', 'email': email};

      final db = await dbHelper.database;

      // Insert or replace user locally
      try {
        // check existing
        final existing = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
        int? userId;
        if (existing.isNotEmpty) {
          userId = existing.first['id'] as int?;
          await db.update('users', {
            'name': userData['name'] ?? existing.first['name'],
            'email': userData['email'] ?? existing.first['email'],
            'password': password,
            'phone': userData['phone'] ?? existing.first['phone'] ?? '',
            'address': userData['address'] ?? existing.first['address'] ?? '',
            'foto_profil': userData['foto_profil'] ?? existing.first['foto_profil'] ?? '',
          }, where: 'id = ?', whereArgs: [userId]);
        } else {
          userId = await db.insert('users', {
            'name': userData['name'] ?? '',
            'email': userData['email'] ?? email,
            'password': password,
            'phone': userData['phone'] ?? '',
            'address': userData['address'] ?? '',
            'foto_profil': userData['foto_profil'] ?? '',
            'created_at': userData['created_at'] ?? DateTime.now().toIso8601String(),
          });
        }

        // Clear old session and insert new session with token
        await db.delete('session');
        await db.insert('session', {
          'is_login': 1,
          'user_id': userId,
          'token': token,
        });
      } catch (e) {
        print('Warning: failed to save user/session locally: $e');
      }

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
      final token = sessions.first['token'] as String? ?? '';

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

      final user = UserModel.fromMap(users.first);
      // attach token to user model's foto_profil or other field if you need token accessible;
      // better: provide separate getter to retrieve token when needed
      return user;
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

  // Helper to get current token from session
  Future<String> getToken() async {
    try {
      final db = await dbHelper.database;
      final sessions = await db.query('session', where: 'is_login = ?', whereArgs: [1], limit: 1);
      if (sessions.isEmpty) return '';
      return sessions.first['token'] as String? ?? '';
    } catch (e) {
      return '';
    }
  }
}