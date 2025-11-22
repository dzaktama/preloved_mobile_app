import 'package:hive/hive.dart';

part 'userModel.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? uId;

  @HiveField(1)
  String? uName;

  @HiveField(2)
  String? uEmail;

  @HiveField(3)
  String? uPassword;

  @HiveField(4)
  String? uPhone;

  @HiveField(5)
  String? uAddress;

  @HiveField(6)
  String? uFotoProfil;

  @HiveField(7)
  String? uRole;

  @HiveField(8)
  List<String>? daftarAlamat;

  UserModel({
    this.uId,
    this.uName,
    this.uEmail,
    this.uPassword,
    this.uPhone,
    this.uAddress,
    this.uFotoProfil,
    this.uRole = 'user',
    this.daftarAlamat,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uId: map['uId'],
      uName: map['uName'],
      uEmail: map['uEmail'],
      uPassword: map['uPassword'],
      uPhone: map['uPhone'],
      uAddress: map['uAddress'],
      uFotoProfil: map['uFotoProfil'],
      uRole: map['uRole'] ?? 'user',
      daftarAlamat: map['daftarAlamat'] != null 
          ? List<String>.from(map['daftarAlamat']) 
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'uName': uName,
      'uEmail': uEmail,
      'uPassword': uPassword,
      'uPhone': uPhone,
      'uAddress': uAddress,
      'uFotoProfil': uFotoProfil,
      'uRole': uRole,
      'daftarAlamat': daftarAlamat,
    };
  }
}