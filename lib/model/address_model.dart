import 'package:hive/hive.dart';

part 'address_model.g.dart';

@HiveType(typeId: 4)
class AddressModel extends HiveObject {
  @HiveField(0)
  String? idAddress;

  @HiveField(1)
  String? idUser;

  @HiveField(2)
  String? namaLengkap;

  @HiveField(3)
  String? nomorTelepon;

  @HiveField(4)
  String? alamatLengkap;

  @HiveField(5)
  String? kota;

  @HiveField(6)
  String? provinsi;

  @HiveField(7)
  String? kodePos;

  @HiveField(8)
  bool? isPrimary;

  @HiveField(9)
  String? label; // Rumah, Kantor, dll

  AddressModel({
    this.idAddress,
    this.idUser,
    this.namaLengkap,
    this.nomorTelepon,
    this.alamatLengkap,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.isPrimary = false,
    this.label = 'Rumah',
  });

  // Generate ID unik
  String generateId() {
    return 'ADDR_${idUser}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Map<String, dynamic> toMap() {
    return {
      'idAddress': idAddress,
      'idUser': idUser,
      'namaLengkap': namaLengkap,
      'nomorTelepon': nomorTelepon,
      'alamatLengkap': alamatLengkap,
      'kota': kota,
      'provinsi': provinsi,
      'kodePos': kodePos,
      'isPrimary': isPrimary,
      'label': label,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      idAddress: map['idAddress'],
      idUser: map['idUser'],
      namaLengkap: map['namaLengkap'],
      nomorTelepon: map['nomorTelepon'],
      alamatLengkap: map['alamatLengkap'],
      kota: map['kota'],
      provinsi: map['provinsi'],
      kodePos: map['kodePos'],
      isPrimary: map['isPrimary'] ?? false,
      label: map['label'] ?? 'Rumah',
    );
  }

  String get alamatSingkat {
    return '$kota, $provinsi';
  }
}