import 'package:hive/hive.dart';

part 'akun_user_model.g.dart'; // Baris ini akan merah SEBELUM generate, abaikan dulu.

@HiveType(typeId: 0)
class AkunUserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  String noHp;

  @HiveField(4)
  String fotoProfil;

  @HiveField(5)
  String role;

  AkunUserModel({
    required this.username,
    required this.email,
    required this.password,
    required this.noHp,
    required this.fotoProfil,
    this.role = 'user',
  });
}