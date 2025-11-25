class UserModel {
  int? id;
  String? uName;
  String? uEmail;
  String? uPassword;
  String? uPhone;
  String? uAddress;
  String? uFotoProfil;
  String? uRole;
  String? createdAt;

  UserModel({
    this.id,
    this.uName,
    this.uEmail,
    this.uPassword,
    this.uPhone,
    this.uAddress,
    this.uFotoProfil,
    this.uRole = 'user',
    this.createdAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': uName,
      'email': uEmail,
      'password': uPassword,
      'phone': uPhone,
      'address': uAddress,
      'foto_profil': uFotoProfil,
      'role': uRole,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      uName: map['name'] as String?,
      uEmail: map['email'] as String?,
      uPassword: map['password'] as String?,
      uPhone: map['phone'] as String?,
      uAddress: map['address'] as String?,
      uFotoProfil: map['foto_profil'] as String?,
      uRole: map['role'] as String? ?? 'user',
      createdAt: map['created_at'] as String?,
    );
  }

  UserModel copy({
    int? id,
    String? uName,
    String? uEmail,
    String? uPassword,
    String? uPhone,
    String? uAddress,
    String? uFotoProfil,
    String? uRole,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      uName: uName ?? this.uName,
      uEmail: uEmail ?? this.uEmail,
      uPassword: uPassword ?? this.uPassword,
      uPhone: uPhone ?? this.uPhone,
      uAddress: uAddress ?? this.uAddress,
      uFotoProfil: uFotoProfil ?? this.uFotoProfil,
      uRole: uRole ?? this.uRole,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}