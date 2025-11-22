import 'package:hive/hive.dart';

part 'barang_model.g.dart';

@HiveType(typeId: 1)
class BarangJualanModel extends HiveObject {
  @HiveField(0)
  String namaBarang;

  @HiveField(1)
  String harga;

  @HiveField(2)
  String kategori;

  @HiveField(3)
  String kondisi;

  @HiveField(4)
  String ukuran;

  @HiveField(5)
  String brand;

  @HiveField(6)
  String bahan;

  @HiveField(7)
  String deskripsi;

  @HiveField(8)
  String lokasi;

  @HiveField(9)
  String kontakPenjual;

  @HiveField(10)
  String pathGambar; // Path lokal foto

  @HiveField(11)
  String idPenjual; // ID user yang upload

  @HiveField(12)
  DateTime tanggalUpload;

  BarangJualanModel({
    required this.namaBarang,
    required this.harga,
    required this.kategori,
    required this.kondisi,
    required this.ukuran,
    required this.brand,
    required this.bahan,
    required this.deskripsi,
    required this.lokasi,
    required this.kontakPenjual,
    required this.pathGambar,
    required this.idPenjual,
    required this.tanggalUpload,
  });

  // Generate ID unik
  String get id {
    return '${idPenjual}_${tanggalUpload.millisecondsSinceEpoch}';
  }
}