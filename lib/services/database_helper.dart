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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Table Users
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
        created_at $textType
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
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Helper method untuk clear semua data (untuk testing)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('item_transaksi');
    await db.delete('transaksi');
    await db.delete('cart');
    await db.delete('barang_jualan');
    await db.delete('addresses');
    await db.delete('session');
    await db.delete('users');
  }
}
