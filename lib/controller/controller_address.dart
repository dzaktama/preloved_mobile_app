import '../model/address_model.dart';
import '../services/database_helper.dart';

class AddressController {
  final dbHelper = DatabaseHelper.instance;

  // Tambah alamat baru
  Future<bool> tambahAlamat(AddressModel alamat) async {
    try {
      final db = await dbHelper.database;

      // Jika ini alamat pertama atau set sebagai primary, update alamat lain
      if (alamat.isPrimary == true) {
        await _setPrimaryAddress(alamat.userId!, null);
      }

      await db.insert('addresses', alamat.toMap());
      return true;
    } catch (e) {
      print('Error tambahAlamat: $e');
      return false;
    }
  }

  // Ambil semua alamat user
  Future<List<AddressModel>> ambilAlamatUser(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'addresses',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'is_primary DESC',
      );

      return List.generate(maps.length, (i) {
        return AddressModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error ambilAlamatUser: $e');
      return [];
    }
  }

  // Ambil primary address
  Future<AddressModel?> ambilPrimaryAddress(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'addresses',
        where: 'user_id = ? AND is_primary = ?',
        whereArgs: [userId, 1],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return AddressModel.fromMap(maps.first);
    } catch (e) {
      print('Error ambilPrimaryAddress: $e');
      return null;
    }
  }

  // Set alamat sebagai primary
  Future<bool> setPrimaryAddress(int userId, int addressId) async {
    try {
      await _setPrimaryAddress(userId, addressId);
      return true;
    } catch (e) {
      print('Error setPrimaryAddress: $e');
      return false;
    }
  }

  Future<void> _setPrimaryAddress(int userId, int? addressId) async {
    final db = await dbHelper.database;

    // Set semua alamat user jadi false
    await db.update(
      'addresses',
      {'is_primary': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Set alamat yang dipilih jadi true
    if (addressId != null) {
      await db.update(
        'addresses',
        {'is_primary': 1},
        where: 'id = ?',
        whereArgs: [addressId],
      );
    }
  }

  // Update alamat
  Future<bool> updateAlamat(AddressModel alamat) async {
    try {
      final db = await dbHelper.database;

      // Jika diset sebagai primary
      if (alamat.isPrimary == true) {
        await _setPrimaryAddress(alamat.userId!, alamat.id);
      }

      await db.update(
        'addresses',
        alamat.toMap(),
        where: 'id = ?',
        whereArgs: [alamat.id],
      );

      return true;
    } catch (e) {
      print('Error updateAlamat: $e');
      return false;
    }
  }

  // Hapus alamat
  Future<bool> hapusAlamat(AddressModel alamat) async {
    try {
      final db = await dbHelper.database;

      bool wasPrimary = alamat.isPrimary == true;
      int userId = alamat.userId!;

      await db.delete(
        'addresses',
        where: 'id = ?',
        whereArgs: [alamat.id],
      );

      // Jika yang dihapus primary, set alamat pertama sebagai primary
      if (wasPrimary) {
        final addresses = await ambilAlamatUser(userId);
        if (addresses.isNotEmpty) {
          await db.update(
            'addresses',
            {'is_primary': 1},
            where: 'id = ?',
            whereArgs: [addresses.first.id],
          );
        }
      }

      return true;
    } catch (e) {
      print('Error hapusAlamat: $e');
      return false;
    }
  }
}