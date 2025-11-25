class AddressModel {
  int? id;
  int? userId;
  String? namaLengkap;
  String? nomorTelepon;
  String? alamatLengkap;
  String? kota;
  String? provinsi;
  String? kodePos;
  bool? isPrimary;
  String? label;

  AddressModel({
    this.id,
    this.userId,
    this.namaLengkap,
    this.nomorTelepon,
    this.alamatLengkap,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.isPrimary = false,
    this.label = 'Rumah',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'nomor_telepon': nomorTelepon,
      'alamat_lengkap': alamatLengkap,
      'kota': kota,
      'provinsi': provinsi,
      'kode_pos': kodePos,
      'is_primary': isPrimary == true ? 1 : 0,
      'label': label,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      namaLengkap: map['nama_lengkap'] as String?,
      nomorTelepon: map['nomor_telepon'] as String?,
      alamatLengkap: map['alamat_lengkap'] as String?,
      kota: map['kota'] as String?,
      provinsi: map['provinsi'] as String?,
      kodePos: map['kode_pos'] as String?,
      isPrimary: map['is_primary'] == 1,
      label: map['label'] as String? ?? 'Rumah',
    );
  }

  String get alamatSingkat {
    return '$kota, $provinsi';
  }

  AddressModel copy({
    int? id,
    int? userId,
    String? namaLengkap,
    String? nomorTelepon,
    String? alamatLengkap,
    String? kota,
    String? provinsi,
    String? kodePos,
    bool? isPrimary,
    String? label,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      alamatLengkap: alamatLengkap ?? this.alamatLengkap,
      kota: kota ?? this.kota,
      provinsi: provinsi ?? this.provinsi,
      kodePos: kodePos ?? this.kodePos,
      isPrimary: isPrimary ?? this.isPrimary,
      label: label ?? this.label,
    );
  }
}