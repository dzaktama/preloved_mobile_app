import 'package:hive_flutter/hive_flutter.dart';
import '../model/cart_model.dart';

class ControllerCart {
  Future<void> tambahKeCart(String idProduk, int jumlah) async {
    var box = await Hive.openBox<CartModel>('box_cart');
    
    CartModel? existing;
    try {
      existing = box.values.firstWhere((item) => item.idProduk == idProduk);
    } catch (e) {
      existing = null;
    }

    if (existing != null && existing.idProduk != null) {
      existing.jumlah = (existing.jumlah ?? 0) + jumlah;
      await existing.save();
    } else {
      await box.add(CartModel(idProduk: idProduk, jumlah: jumlah));
    }
  }

  Future<void> updateJumlah(String idProduk, int jumlahBaru) async {
    var box = await Hive.openBox<CartModel>('box_cart');
    
    try {
      var item = box.values.firstWhere((c) => c.idProduk == idProduk);
      if (jumlahBaru <= 0) {
        await item.delete();
      } else {
        item.jumlah = jumlahBaru;
        await item.save();
      }
    } catch (e) {
      // Item tidak ditemukan
    }
  }

  Future<void> hapusDariCart(String idProduk) async {
    var box = await Hive.openBox<CartModel>('box_cart');
    
    try {
      var item = box.values.firstWhere((c) => c.idProduk == idProduk);
      await item.delete();
    } catch (e) {
      // Item tidak ditemukan
    }
  }

  Future<Map<String, int>> ambilSemuaCart() async {
    var box = await Hive.openBox<CartModel>('box_cart');
    Map<String, int> cart = {};
    
    for (var item in box.values) {
      if (item.idProduk != null && item.jumlah != null) {
        cart[item.idProduk!] = item.jumlah!;
      }
    }
    
    return cart;
  }

  Future<void> kosongkanCart() async {
    var box = await Hive.openBox<CartModel>('box_cart');
    await box.clear();
  }

  Future<int> hitungTotalItem() async {
    var box = await Hive.openBox<CartModel>('box_cart');
    return box.values.length;
  }
}