import '../model/userModel.dart';
import '../services/database_helper.dart';
import '../services/layanan_api.dart';
import 'dart:convert';

class AuthController {
  final dbHelper = DatabaseHelper.instance;
  final ApiService _api = ApiService();

  // ==================== REGISTER ====================
  /// Register user baru via API, kemudian simpan data lokal
  Future<bool> register(UserModel userBaru) async {
    try {
      final body = {
        'name': userBaru.uName ?? '',
        'email': userBaru.uEmail ?? '',
        'password': userBaru.uPassword ?? '',
        'phone': userBaru.uPhone ?? '', // API requires phone
      };

      print('AuthController.register -> request: ${json.encode(body)}');
      final res = await _api.registerUser(body);
      print('AuthController.register -> response: $res');

      if (res['success']) {
        // Simpan user ke database lokal (opsional)
        try {
          final data = res['data'];
          final db = await dbHelper.database;
          
          final userMap = <String, dynamic>{
            'name': data['name'] ?? userBaru.uName,
            'email': data['email'] ?? userBaru.uEmail,
            'password': userBaru.uPassword, // Simpan password untuk login lokal
            'phone': data['phone'] ?? userBaru.uPhone ?? '',
            'address': data['address'] ?? userBaru.uAddress ?? '',
            'foto_profil': data['foto_profil'] ?? '',
            'role': data['role'] ?? 'user',
            'created_at': data['createdAt'] ?? data['created_at'] ?? DateTime.now().toIso8601String(),
          };

          await db.insert('users', userMap);
          print('AuthController: User saved locally');
        } catch (e) {
          print('Warning: Failed to save user locally: $e');
        }

        return true;
      }

      print('AuthController.register -> failed: ${res['message']}');
      return false;
    } catch (e) {
      print('Error register: $e');
      return false;
    }
  }

  // ==================== LOGIN ====================
  /// Login via API, simpan token dan user data
  Future<bool> login(String email, String password) async {
    try {
      final body = {'email': email, 'password': password};

      print('AuthController.login -> request: ${json.encode(body)}');
      final res = await _api.loginUser(body);
      print('AuthController.login -> response: $res');

      if (res['success'] != true) {
        print('AuthController.login -> failed: ${res['message']}');
        return false;
      }

      final data = res['data'];
      
      // Extract token dan user data
      String token = '';
      Map<String, dynamic>? userData;

      if (data is Map<String, dynamic>) {
        // Token bisa di berbagai field
        token = data['token'] ?? data['accessToken'] ?? data['access_token'] ?? '';
        
        // User data bisa di berbagai field
        userData = data['user'] ?? data['data'];
        
        // Jika tidak ada user object, fallback ke data utama
        if (userData == null && data.containsKey('name')) {
          userData = data;
        }
      }

      // Fallback jika user data tidak lengkap
      userData ??= {
        'name': '',
        'email': email,
      };

      print('AuthController: Token: ${token.isNotEmpty ? "✓" : "✗"}, User: ${userData['name']}');

      // Simpan ke database lokal
      try {
        final db = await dbHelper.database;

        // Cek apakah user sudah ada
        final existing = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
          limit: 1,
        );

        int? userId;

        if (existing.isNotEmpty) {
          // Update user yang sudah ada
          userId = existing.first['id'] as int?;
          await db.update('users', {
            'name': userData['name'] ?? existing.first['name'],
            'email': userData['email'] ?? existing.first['email'],
            'password': password,
            'phone': userData['phone'] ?? existing.first['phone'] ?? '',
            'address': userData['address'] ?? existing.first['address'] ?? '',
            'foto_profil': userData['foto_profil'] ?? userData['profilePicture'] ?? existing.first['foto_profil'] ?? '',
          }, where: 'id = ?', whereArgs: [userId]);
        } else {
          // Insert user baru
          userId = await db.insert('users', {
            'name': userData['name'] ?? '',
            'email': userData['email'] ?? email,
            'password': password,
            'phone': userData['phone'] ?? '',
            'address': userData['address'] ?? '',
            'foto_profil': userData['foto_profil'] ?? userData['profilePicture'] ?? '',
            'role': userData['role'] ?? 'user',
            'created_at': userData['createdAt'] ?? userData['created_at'] ?? DateTime.now().toIso8601String(),
          });
        }

        // Simpan session dengan token
        await db.delete('session'); // Clear old sessions
        await db.insert('session', {
          'is_login': 1,
          'user_id': userId,
          'token': token,
        });

        print('AuthController: Login saved locally (userId: $userId)');
      } catch (e) {
        print('Warning: Failed to save login session: $e');
      }

      return true;
    } catch (e) {
      print('Error login: $e');
      return false;
    }
  }

  // ==================== GET USER LOGIN ====================
  /// Ambil data user yang sedang login dari database lokal
  Future<UserModel?> getUserLogin() async {
    try {
      final db = await dbHelper.database;

      // Ambil session aktif
      final sessions = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (sessions.isEmpty) {
        print('AuthController: No active session');
        return null;
      }

      final userId = sessions.first['user_id'] as int;
      final token = sessions.first['token'] as String? ?? '';

      // Ambil data user
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        print('AuthController: User not found');
        return null;
      }

      final user = UserModel.fromMap(users.first);
      print('AuthController: User loaded: ${user.uName} (${user.uEmail})');
      
      return user;
    } catch (e) {
      print('Error getUserLogin: $e');
      return null;
    }
  }

  // ==================== UPDATE USER ====================
  /// Update user data di database lokal
  /// Untuk sinkronisasi dengan API, gunakan updateProfileAPI()
  Future<bool> updateUser(UserModel user) async {
    try {
      final db = await dbHelper.database;

      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );

      print('AuthController: User updated locally');
      return true;
    } catch (e) {
      print('Error updateUser: $e');
      return false;
    }
  }

  // ==================== UPDATE PROFILE VIA API ====================
  /// Update profile via API (memerlukan token)
  Future<bool> updateProfileAPI(Map<String, dynamic> updates) async {
    try {
      final token = await getToken();
      if (token.isEmpty) {
        print('AuthController: No token found');
        return false;
      }

      print('AuthController.updateProfileAPI -> updates: ${json.encode(updates)}');
      final res = await _api.updateProfile(token, updates);
      print('AuthController.updateProfileAPI -> response: $res');

      if (res['success']) {
        // Update juga data lokal
        final userData = res['data'];
        if (userData != null) {
          final user = await getUserLogin();
          if (user != null) {
            final updatedUser = user.copy(
              uName: userData['name'] ?? user.uName,
              uEmail: userData['email'] ?? user.uEmail,
              uPhone: userData['phone'] ?? user.uPhone,
              uAddress: userData['address'] ?? user.uAddress,
              uFotoProfil: userData['foto_profil'] ?? userData['profilePicture'] ?? user.uFotoProfil,
              uRole: userData['role'] ?? user.uRole,
            );
            await updateUser(updatedUser);
          }
        }
        return true;
      }

      return false;
    } catch (e) {
      print('Error updateProfileAPI: $e');
      return false;
    }
  }

  // ==================== UPDATE PASSWORD VIA API ====================
  /// Update password via API
  Future<bool> updatePasswordAPI(String currentPassword, String newPassword) async {
    try {
      final token = await getToken();
      if (token.isEmpty) {
        print('AuthController: No token found');
        return false;
      }

      final body = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };

      print('AuthController.updatePasswordAPI -> request');
      final res = await _api.updatePassword(token, body);
      print('AuthController.updatePasswordAPI -> response: $res');

      if (res['success']) {
        // Update password lokal juga
        final user = await getUserLogin();
        if (user != null) {
          final db = await dbHelper.database;
          await db.update(
            'users',
            {'password': newPassword},
            where: 'id = ?',
            whereArgs: [user.id],
          );
        }
        return true;
      }

      return false;
    } catch (e) {
      print('Error updatePasswordAPI: $e');
      return false;
    }
  }

  // ==================== GET PROFILE FROM API ====================
  /// Refresh profile dari API (sinkronisasi data terbaru)
  Future<Map<String, dynamic>?> refreshProfile() async {
    try {
      final token = await getToken();
      if (token.isEmpty) {
        print('AuthController: No token found');
        return null;
      }

      print('AuthController.refreshProfile');
      final res = await _api.getProfile(token);
      print('AuthController.refreshProfile -> response: $res');

      if (res['success']) {
        final userData = res['data'];
        
        // Update data lokal
        final user = await getUserLogin();
        if (user != null && userData != null) {
          final updatedUser = user.copy(
            uName: userData['name'] ?? user.uName,
            uEmail: userData['email'] ?? user.uEmail,
            uPhone: userData['phone'] ?? user.uPhone,
            uAddress: userData['address'] ?? user.uAddress,
            uFotoProfil: userData['foto_profil'] ?? userData['profilePicture'] ?? user.uFotoProfil,
            uRole: userData['role'] ?? user.uRole,
            createdAt: userData['createdAt'] ?? userData['created_at'] ?? user.createdAt,
          );
          await updateUser(updatedUser);
        }

        return userData;
      }

      return null;
    } catch (e) {
      print('Error refreshProfile: $e');
      return null;
    }
  }

  // ==================== CEK SESI ====================
  /// Cek apakah user sedang login (untuk splash screen)
  Future<bool> cekSesi() async {
    try {
      final db = await dbHelper.database;

      final sessions = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
      );

      final hasSession = sessions.isNotEmpty;
      print('AuthController: Session check: ${hasSession ? "Active" : "Inactive"}');
      
      return hasSession;
    } catch (e) {
      print('Error cekSesi: $e');
      return false;
    }
  }

  // ==================== LOGOUT ====================
  /// Logout user (hapus session lokal)
  Future<void> logout() async {
    try {
      final db = await dbHelper.database;
      await db.delete('session');
      print('AuthController: Logged out');
    } catch (e) {
      print('Error logout: $e');
    }
  }

  // ==================== GET TOKEN ====================
  /// Helper untuk mendapatkan token dari session
  Future<String> getToken() async {
    try {
      final db = await dbHelper.database;
      final sessions = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (sessions.isEmpty) return '';

      final token = sessions.first['token'] as String? ?? '';
      return token;
    } catch (e) {
      print('Error getToken: $e');
      return '';
    }
  }

  // ==================== GET USER ID ====================
  /// Helper untuk mendapatkan user ID yang sedang login
  Future<int?> getUserId() async {
    try {
      final db = await dbHelper.database;
      final sessions = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (sessions.isEmpty) return null;

      return sessions.first['user_id'] as int?;
    } catch (e) {
      print('Error getUserId: $e');
      return null;
    }
  }
}