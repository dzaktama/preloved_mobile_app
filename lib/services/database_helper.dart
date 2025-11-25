import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('preloved.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // UPDATED VERSION untuk migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambah kolom rating di users table
      await db.execute('ALTER TABLE users ADD COLUMN rating REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE users ADD COLUMN total_reviews INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE users ADD COLUMN response_rate REAL DEFAULT 100.0');
      await db.execute('ALTER TABLE users ADD COLUMN bio TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN join_date TEXT');
      
      // Create chat tables
      await _createChatTables(db);
      
      // Create review table
      await _createReviewTable(db);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Table Users (UPDATED with new fields)
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType UNIQUE,
        password $textType,
        phone $textTypeNull,
        address $textTypeNull,
        foto_profil $textTypeNull,
        role $textType DEFAULT 'user',
        created_at $textType,
        rating REAL DEFAULT 0.0,
        total_reviews INTEGER DEFAULT 0,
        response_rate REAL DEFAULT 100.0,
        bio $textTypeNull,
        join_date $textTypeNull
      )
    ''');

    // Table Session
    await db.execute('''
      CREATE TABLE session (
        id $idType,
        is_login $intType DEFAULT 0,
        user_id $intType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Addresses
    await db.execute('''
      CREATE TABLE addresses (
        id $idType,
        user_id $intType,
        nama_lengkap $textType,
        nomor_telepon $textType,
        alamat_lengkap $textType,
        kota $textType,
        provinsi $textType,
        kode_pos $textType,
        is_primary $intType DEFAULT 0,
        label $textType DEFAULT 'Rumah',
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Barang Jualan
    await db.execute('''
      CREATE TABLE barang_jualan (
        id $idType,
        nama_barang $textType,
        harga $textType,
        kategori $textType,
        kondisi $textType,
        ukuran $textType,
        brand $textType,
        bahan $textType,
        deskripsi $textType,
        lokasi $textType,
        kontak_penjual $textType,
        path_gambar $textType,
        id_penjual $intType,
        tanggal_upload $textType,
        FOREIGN KEY (id_penjual) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Cart
    await db.execute('''
      CREATE TABLE cart (
        id $idType,
        user_id $intType,
        id_produk $textType,
        jumlah $intType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Transaksi
    await db.execute('''
      CREATE TABLE transaksi (
        id $idType,
        id_transaksi $textType UNIQUE,
        user_id $intType,
        tanggal_transaksi $textType,
        total_harga $realType,
        ongkir $realType,
        status $textType,
        metode_pembayaran $textTypeNull,
        alamat_pengiriman $textTypeNull,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Item Transaksi
    await db.execute('''
      CREATE TABLE item_transaksi (
        id $idType,
        transaksi_id $intType,
        id_produk $textType,
        nama_produk $textType,
        brand $textTypeNull,
        jumlah $intType,
        harga $realType,
        gambar $textTypeNull,
        FOREIGN KEY (transaksi_id) REFERENCES transaksi (id) ON DELETE CASCADE
      )
    ''');

    // Create chat tables
    await _createChatTables(db);
    
    // Create review table
    await _createReviewTable(db);
  }

  Future<void> _createChatTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    // Table Chat Rooms (Conversation between 2 users)
    await db.execute('''
      CREATE TABLE chat_rooms (
        id $idType,
        user1_id $intType,
        user2_id $intType,
        last_message $textTypeNull,
        last_message_time $textTypeNull,
        unread_count_user1 INTEGER DEFAULT 0,
        unread_count_user2 INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (user1_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (user2_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user1_id, user2_id)
      )
    ''');

    // Table Messages
    await db.execute('''
      CREATE TABLE messages (
        id $idType,
        chat_room_id $intType,
        sender_id $intType,
        receiver_id $intType,
        message $textType,
        is_read INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (chat_room_id) REFERENCES chat_rooms (id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createReviewTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Table Reviews
    await db.execute('''
      CREATE TABLE reviews (
        id $idType,
        seller_id $intType,
        buyer_id $intType,
        transaksi_id $textTypeNull,
        rating $realType,
        review_text $textTypeNull,
        created_at $textType,
        FOREIGN KEY (seller_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (buyer_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Helper method untuk clear semua data (untuk testing)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('messages');
    await db.delete('chat_rooms');
    await db.delete('reviews');
    await db.delete('item_transaksi');
    await db.delete('transaksi');
    await db.delete('cart');
    await db.delete('barang_jualan');
    await db.delete('addresses');
    await db.delete('session');
    await db.delete('users');
  }
}