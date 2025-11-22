import 'package:hive/hive.dart';

part 'transaksi_model.g.dart';

@HiveType(typeId: 1)
class TransaksiModel extends HiveObject {
  @HiveField(0)
  String? idTransaksi;

  @HiveField(1)
  String? idUser;

  @HiveField(2)
  DateTime? tanggalTransaksi;

  @HiveField(3)
  List<ItemTransaksi>? items;

  @HiveField(4)
  double? totalHarga;

  @HiveField(5)
  String? status;

  @HiveField(6)
  String? metodePembayaran;

  @HiveField(7)
  String? alamatPengiriman;

  @HiveField(8)
  double? ongkir;

  TransaksiModel({
    this.idTransaksi,
    this.idUser,
    this.tanggalTransaksi,
    this.items,
    this.totalHarga,
    this.status,
    this.metodePembayaran,
    this.alamatPengiriman,
    this.ongkir,
  });

  double get grandTotal => (totalHarga ?? 0) + (ongkir ?? 0);
}

@HiveType(typeId: 2)
class ItemTransaksi extends HiveObject {
  @HiveField(0)
  String? idProduk;

  @HiveField(1)
  String? namaProduk;

  @HiveField(2)
  int? jumlah;

  @HiveField(3)
  double? harga;

  @HiveField(4)
  String? gambar;

  @HiveField(5)
  String? brand;

  ItemTransaksi({
    this.idProduk,
    this.namaProduk,
    this.jumlah,
    this.harga,
    this.gambar,
    this.brand,
  });

  double get subtotal => (harga ?? 0) * (jumlah ?? 0);
}