// Ini cuma model data biasa, tidak perlu import Firebase lagi.
class UserModel {
  String? uId;
  String? uName;
  String? uEmail;
  String? uPassword;
  String? uPhone;
  String? uAddress;

  UserModel({
    this.uId,
    this.uName,
    this.uEmail,
    this.uPassword,
    this.uPhone,
    this.uAddress,
  });

  // Konversi dari Map (Database Lokal) ke Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uId: map['uId'],
      uName: map['uName'],
      uEmail: map['uEmail'],
      uPassword: map['uPassword'],
      uPhone: map['uPhone'],
      uAddress: map['uAddress'],
    );
  }

  // Konversi dari Object ke Map (Untuk disimpan)
  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'uName': uName,
      'uEmail': uEmail,
      'uPassword': uPassword,
      'uPhone': uPhone,
      'uAddress': uAddress,
    };
  }
}