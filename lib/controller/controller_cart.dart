import '../model/cart_model.dart';
import '../services/database_helper.dart';
import 'auth_controller.dart';

class ControllerCart {
  final dbHelper = DatabaseHelper.instance;
  final authController = AuthController();

  Future<int?> _getCurrentUserId() async {
    final user = await authController.getUserLogin();
    return user?.id;
  }

  Future<void> tambahKeCart(String idProduk, int jumlah) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final db = await dbHelper.database;

      // Cek apakah produk sudah ada di cart
      final List<Map<String, dynamic>> existing = await db.query(
        'cart',
        where: 'user_id = ? AND id_produk = ?',
        whereArgs: [userId, idProduk],
      );

      if (existing.isNotEmpty) {
        // Update jumlah
        final currentJumlah = existing.first['jumlah'] as int;
        await db.update(
          'cart',
          {'jumlah': currentJumlah + jumlah},
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        // Insert baru
        await db.insert('cart', {
          'user_id': userId,
          'id_produk': idProduk,
          'jumlah': jumlah,
        });
      }
    } catch (e) {
      print('Error tambahKeCart: $e');
    }
  }

  Future<void> updateJumlah(String idProduk, int jumlahBaru) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final db = await dbHelper.database;

      if (jumlahBaru <= 0) {
        // Hapus dari cart
        await db.delete(
          'cart',
          where: 'user_id = ? AND id_produk = ?',
          whereArgs: [userId, idProduk],
        );
      } else {
        // Update jumlah
        await db.update(
          'cart',
          {'jumlah': jumlahBaru},
          where: 'user_id = ? AND id_produk = ?',
          whereArgs: [userId, idProduk],
        );
      }
    } catch (e) {
      print('Error updateJumlah: $e');
    }
  }

  Future<void> hapusDariCart(String idProduk) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final db = await dbHelper.database;

      await db.delete(
        'cart',
        where: 'user_id = ? AND id_produk = ?',
        whereArgs: [userId, idProduk],
      );
    } catch (e) {
      print('Error hapusDariCart: $e');
    }
  }

  Future<Map<String, int>> ambilSemuaCart() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return {};

      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'cart',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      Map<String, int> cart = {};
      for (var map in maps) {
        cart[map['id_produk'] as String] = map['jumlah'] as int;
      }

      return cart;
    } catch (e) {
      print('Error ambilSemuaCart: $e');
      return {};
    }
  }

  Future<void> kosongkanCart() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      final db = await dbHelper.database;

      await db.delete(
        'cart',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error kosongkanCart: $e');
    }
  }

  Future<int> hitungTotalItem() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return 0;

      final db = await dbHelper.database;

      final List<Map<String, dynamic>> result = await db.query(
        'cart',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return result.length;
    } catch (e) {
      print('Error hitungTotalItem: $e');
      return 0;
    }
  }
}