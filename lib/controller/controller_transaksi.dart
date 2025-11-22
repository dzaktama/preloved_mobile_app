import 'package:hive_flutter/hive_flutter.dart';
import '../model/transaksi_model.dart';

class ControllerTransaksi {
  Future<bool> simpanTransaksi(TransaksiModel transaksi) async {
    try {
      var box = await Hive.openBox<TransaksiModel>('box_transaksi');
      await box.add(transaksi);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    var box = await Hive.openBox<TransaksiModel>('box_transaksi');
    return box.values.toList();
  }

  Future<List<TransaksiModel>> ambilTransaksiByUser(String idUser) async {
    var box = await Hive.openBox<TransaksiModel>('box_transaksi');
    return box.values.where((transaksi) => transaksi.idUser == idUser).toList()
      ..sort((a, b) => (b.tanggalTransaksi ?? DateTime.now()).compareTo(a.tanggalTransaksi ?? DateTime.now()));
  }

  Future<TransaksiModel?> ambilTransaksiById(String idTransaksi) async {
    var box = await Hive.openBox<TransaksiModel>('box_transaksi');
    try {
      return box.values.firstWhere((transaksi) => transaksi.idTransaksi == idTransaksi);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateStatusTransaksi(String idTransaksi, String statusBaru) async {
    try {
      var box = await Hive.openBox<TransaksiModel>('box_transaksi');
      var transaksi = box.values.firstWhere((t) => t.idTransaksi == idTransaksi);
      transaksi.status = statusBaru;
      await transaksi.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hapusTransaksi(String idTransaksi) async {
    try {
      var box = await Hive.openBox<TransaksiModel>('box_transaksi');
      var transaksi = box.values.firstWhere((t) => t.idTransaksi == idTransaksi);
      await transaksi.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}