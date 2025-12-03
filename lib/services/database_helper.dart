// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('preloved_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // ⚠️ PENTING: Naikkan version untuk trigger migration
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Create tables untuk database baru
  Future<void> _createDB(Database db, int version) async {
    print('🔵 Creating database version $version...');
    
    // Tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        address TEXT,
        foto_profil TEXT,
        password TEXT NOT NULL,
        created_at TEXT,
        token TEXT
      )
    ''');

    // Tabel barang_jualan dengan kolom lengkap
    await db.execute('''
      CREATE TABLE barang_jualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL,
        harga TEXT NOT NULL,
        kategori TEXT NOT NULL,
        kondisi TEXT NOT NULL,
        ukuran TEXT NOT NULL,
        brand TEXT NOT NULL,
        bahan TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        lokasi TEXT NOT NULL,
        kontak_penjual TEXT NOT NULL,
        path_gambar TEXT,
        gambar_url TEXT,
        id_penjual INTEGER NOT NULL,
        user_id TEXT,
        tanggal_upload TEXT NOT NULL,
        FOREIGN KEY (id_penjual) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ✅ TABEL SESSION (BARU)
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        token TEXT,
        is_login INTEGER DEFAULT 0,
        last_login TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    print('✅ Database created successfully with session table');
  }

  // Upgrade database untuk versi lama
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion...');

    // Upgrade dari v1 ke v2
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE barang_jualan ADD COLUMN gambar_url TEXT');
        print('✅ Added column: gambar_url');
      } catch (e) {
        print('⚠️ Column gambar_url might already exist: $e');
      }
    }

    // Upgrade dari v2 ke v3
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE barang_jualan ADD COLUMN user_id TEXT');
        print('✅ Added column: user_id');
      } catch (e) {
        print('⚠️ Column user_id might already exist: $e');
      }
    }

    // Upgrade dari v3 ke v4 - TAMBAH TABEL SESSION
    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS session (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            token TEXT,
            is_login INTEGER DEFAULT 0,
            last_login TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        print('✅ Created table: session');
      } catch (e) {
        print('⚠️ Session table might already exist: $e');
      }
    }

    print('✅ Database upgraded successfully');
  }

  // Query helper methods
  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await instance.database;
    return db.query(table);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> update(String table, Map<String, dynamic> row, String where, List<dynamic> whereArgs) async {
    final db = await instance.database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Clear all data (untuk testing)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('barang_jualan');
    await db.delete('users');
    await db.delete('session');
    print('✅ All data cleared');
  }

  // Delete database (untuk fresh start)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'preloved_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('✅ Database deleted');
  }

  // Check database schema
  Future<void> checkSchema() async {
    final db = await instance.database;
    
    print('🔍 Checking database schema...');
    
    // Check barang_jualan table structure
    final barangSchema = await db.rawQuery('PRAGMA table_info(barang_jualan)');
    print('📋 barang_jualan columns:');
    for (var col in barangSchema) {
      print('   - ${col['name']} (${col['type']})');
    }
    
    // Check users table structure
    final usersSchema = await db.rawQuery('PRAGMA table_info(users)');
    print('📋 users columns:');
    for (var col in usersSchema) {
      print('   - ${col['name']} (${col['type']})');
    }

    // Check session table structure
    try {
      final sessionSchema = await db.rawQuery('PRAGMA table_info(session)');
      print('📋 session columns:');
      for (var col in sessionSchema) {
        print('   - ${col['name']} (${col['type']})');
      }
    } catch (e) {
      print('⚠️ Session table does not exist: $e');
    }
  }

  // ==================== SESSION METHODS ====================
  
  /// Simpan session login
  Future<bool> saveSession({
    required int userId,
    required String token,
  }) async {
    try {
      final db = await instance.database;
      
      // Clear previous sessions
      await db.delete('session', where: 'is_login = ?', whereArgs: [1]);
      
      // Insert new session
      await db.insert('session', {
        'user_id': userId,
        'token': token,
        'is_login': 1,
        'last_login': DateTime.now().toIso8601String(),
      });
      
      print('✅ Session saved for user $userId');
      return true;
    } catch (e) {
      print('❌ Error saving session: $e');
      return false;
    }
  }

  /// Get active session
  Future<Map<String, dynamic>?> getActiveSession() async {
    try {
      final db = await instance.database;
      
      final result = await db.query(
        'session',
        where: 'is_login = ?',
        whereArgs: [1],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('❌ Error getting session: $e');
      return null;
    }
  }

  /// Clear session (logout)
  Future<bool> clearSession() async {
    try {
      final db = await instance.database;
      await db.delete('session', where: 'is_login = ?', whereArgs: [1]);
      print('✅ Session cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing session: $e');
      return false;
    }
  }

  /// Update session token
  Future<bool> updateSessionToken(String newToken) async {
    try {
      final db = await instance.database;
      
      final updated = await db.update(
        'session',
        {'token': newToken},
        where: 'is_login = ?',
        whereArgs: [1],
      );
      
      if (updated > 0) {
        print('✅ Session token updated');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating session token: $e');
      return false;
    }
  }
}