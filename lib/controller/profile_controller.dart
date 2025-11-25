import '../model/transaksi_model.dart';
import '../services/database_helper.dart';

class ControllerTransaksi {
  final dbHelper = DatabaseHelper.instance;

  Future<bool> simpanTransaksi(TransaksiModel transaksi) async {
    try {
      final db = await dbHelper.database;

      // Insert transaksi utama
      final transaksiId = await db.insert('transaksi', transaksi.toMap());

      // Insert items transaksi
      if (transaksi.items != null) {
        for (var item in transaksi.items!) {
          item.transaksiId = transaksiId;
          await db.insert('item_transaksi', item.toMap());
        }
      }

      return true;
    } catch (e) {
      print('Error simpanTransaksi: $e');
      return false;
    }
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> transaksiMaps = await db.query(
        'transaksi',
        orderBy: 'tanggal_transaksi DESC',
      );

      List<TransaksiModel> transaksiList = [];

      for (var transaksiMap in transaksiMaps) {
        final transaksi = TransaksiModel.fromMap(transaksiMap);

        // Ambil items untuk transaksi ini
        final List<Map<String, dynamic>> itemMaps = await db.query(
          'item_transaksi',
          where: 'transaksi_id = ?',
          whereArgs: [transaksi.id],
        );

        transaksi.items = List.generate(
          itemMaps.length,
          (i) => ItemTransaksi.fromMap(itemMaps[i]),
        );

        transaksiList.add(transaksi);
      }

      return transaksiList;
    } catch (e) {
      print('Error ambilSemuaTransaksi: $e');
      return [];
    }
  }

  Future<List<TransaksiModel>> ambilTransaksiByUser(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> transaksiMaps = await db.query(
        'transaksi',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_transaksi DESC',
      );

      List<TransaksiModel> transaksiList = [];

      for (var transaksiMap in transaksiMaps) {
        final transaksi = TransaksiModel.fromMap(transaksiMap);

        // Ambil items untuk transaksi ini
        final List<Map<String, dynamic>> itemMaps = await db.query(
          'item_transaksi',
          where: 'transaksi_id = ?',
          whereArgs: [transaksi.id],
        );

        transaksi.items = List.generate(
          itemMaps.length,
          (i) => ItemTransaksi.fromMap(itemMaps[i]),
        );

        transaksiList.add(transaksi);
      }

      return transaksiList;
    } catch (e) {
      print('Error ambilTransaksiByUser: $e');
      return [];
    }
  }

  Future<TransaksiModel?> ambilTransaksiById(String idTransaksi) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> transaksiMaps = await db.query(
        'transaksi',
        where: 'id_transaksi = ?',
        whereArgs: [idTransaksi],
        limit: 1,
      );

      if (transaksiMaps.isEmpty) {
        return null;
      }

      final transaksi = TransaksiModel.fromMap(transaksiMaps.first);

      // Ambil items untuk transaksi ini
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'item_transaksi',
        where: 'transaksi_id = ?',
        whereArgs: [transaksi.id],
      );

      transaksi.items = List.generate(
        itemMaps.length,
        (i) => ItemTransaksi.fromMap(itemMaps[i]),
      );

      return transaksi;
    } catch (e) {
      print('Error ambilTransaksiById: $e');
      return null;
    }
  }

  Future<bool> updateStatusTransaksi(String idTransaksi, String statusBaru) async {
    try {
      final db = await dbHelper.database;

      await db.update(
        'transaksi',
        {'status': statusBaru},
        where: 'id_transaksi = ?',
        whereArgs: [idTransaksi],
      );

      return true;
    } catch (e) {
      print('Error updateStatusTransaksi: $e');
      return false;
    }
  }

  Future<bool> hapusTransaksi(String idTransaksi) async {
    try {
      final db = await dbHelper.database;

      // Ambil transaksi untuk mendapat ID internal
      final List<Map<String, dynamic>> transaksiMaps = await db.query(
        'transaksi',
        where: 'id_transaksi = ?',
        whereArgs: [idTransaksi],
        limit: 1,
      );

      if (transaksiMaps.isEmpty) {
        return false;
      }

      final transaksiId = transaksiMaps.first['id'] as int;

      // Hapus items transaksi dulu (karena foreign key)
      await db.delete(
        'item_transaksi',
        where: 'transaksi_id = ?',
        whereArgs: [transaksiId],
      );

      // Hapus transaksi
      await db.delete(
        'transaksi',
        where: 'id = ?',
        whereArgs: [transaksiId],
      );

      return true;
    } catch (e) {
      print('Error hapusTransaksi: $e');
      return false;
    }
  }
}