class BarangJualanModel {
  int? id;
  String namaBarang;
  String harga;
  String kategori;
  String kondisi;
  String ukuran;
  String brand;
  String bahan;
  String deskripsi;
  String lokasi;
  String kontakPenjual;
  String pathGambar; // Local path untuk gambar lokal
  String? gambarUrl; // URL gambar dari API
  int? idPenjual;
  String? tanggalUpload;
  String? userId; // User ID dari API (bisa string)

  BarangJualanModel({
    this.id,
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
    this.gambarUrl,
    this.idPenjual,
    this.tanggalUpload,
    this.userId,
  });

  // Untuk database lokal
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_barang': namaBarang,
      'harga': harga,
      'kategori': kategori,
      'kondisi': kondisi,
      'ukuran': ukuran,
      'brand': brand,
      'bahan': bahan,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'kontak_penjual': kontakPenjual,
      'path_gambar': pathGambar,
      'gambar_url': gambarUrl,
      'id_penjual': idPenjual,
      'user_id': userId,
      'tanggal_upload': tanggalUpload ?? DateTime.now().toIso8601String(),
    };
  }

  // Dari database lokal
  factory BarangJualanModel.fromMap(Map<String, dynamic> map) {
    return BarangJualanModel(
      id: map['id'] as int?,
      namaBarang: map['nama_barang'] as String,
      harga: map['harga'] as String,
      kategori: map['kategori'] as String,
      kondisi: map['kondisi'] as String,
      ukuran: map['ukuran'] as String,
      brand: map['brand'] as String,
      bahan: map['bahan'] as String,
      deskripsi: map['deskripsi'] as String,
      lokasi: map['lokasi'] as String,
      kontakPenjual: map['kontak_penjual'] as String,
      pathGambar: map['path_gambar'] as String? ?? '',
      gambarUrl: map['gambar_url'] as String?,
      idPenjual: map['id_penjual'] as int?,
      userId: map['user_id'] as String?,
      tanggalUpload: map['tanggal_upload'] as String?,
    );
  }

  // Untuk API request (create/update product)
  Map<String, dynamic> toJson() {
    return {
      'namaBarang': namaBarang,
      'harga': harga.replaceAll(RegExp(r'[^0-9]'), ''), // Hapus "Rp" dan format
      'kategori': kategori,
      'kondisi': kondisi,
      'ukuran': ukuran,
      'brand': brand,
      'bahan': bahan,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'kontakPenjual': kontakPenjual,
      'gambar_barang': gambarUrl ?? pathGambar, // Prioritas URL, fallback ke path
    };
  }

  // Dari API response
  factory BarangJualanModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk convert dynamic ke int
    int? parseIntSafe(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper untuk convert harga
    String parseHarga(dynamic value) {
      if (value == null) return 'Rp 0';
      if (value is String) {
        // Jika sudah ada "Rp", return as is
        if (value.contains('Rp')) return value;
        // Jika angka string, format
        return 'Rp ${value}';
      }
      if (value is int || value is double) {
        return 'Rp ${value}';
      }
      return 'Rp 0';
    }

    return BarangJualanModel(
      id: parseIntSafe(json['id'] ?? json['_id']),
      namaBarang: json['namaBarang'] ?? json['nama_barang'] ?? '',
      harga: parseHarga(json['harga']),
      kategori: json['kategori'] ?? '',
      kondisi: json['kondisi'] ?? 'Baik',
      ukuran: json['ukuran'] ?? 'M',
      brand: json['brand'] ?? '',
      bahan: json['bahan'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      kontakPenjual: json['kontakPenjual'] ?? json['kontak_penjual'] ?? '',
      pathGambar: '', // Tidak ada local path dari API
      gambarUrl: json['gambar_barang'] ?? json['gambarBarang'] ?? json['image'],
      idPenjual: parseIntSafe(json['idPenjual'] ?? json['id_penjual']),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      tanggalUpload: json['createdAt'] ?? json['created_at'] ?? json['tanggal_upload'],
    );
  }

  // Copy method
  BarangJualanModel copy({
    int? id,
    String? namaBarang,
    String? harga,
    String? kategori,
    String? kondisi,
    String? ukuran,
    String? brand,
    String? bahan,
    String? deskripsi,
    String? lokasi,
    String? kontakPenjual,
    String? pathGambar,
    String? gambarUrl,
    int? idPenjual,
    String? userId,
    String? tanggalUpload,
  }) {
    return BarangJualanModel(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      harga: harga ?? this.harga,
      kategori: kategori ?? this.kategori,
      kondisi: kondisi ?? this.kondisi,
      ukuran: ukuran ?? this.ukuran,
      brand: brand ?? this.brand,
      bahan: bahan ?? this.bahan,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
      kontakPenjual: kontakPenjual ?? this.kontakPenjual,
      pathGambar: pathGambar ?? this.pathGambar,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      idPenjual: idPenjual ?? this.idPenjual,
      userId: userId ?? this.userId,
      tanggalUpload: tanggalUpload ?? this.tanggalUpload,
    );
  }

  // Helper getters
  String get displayHarga {
    if (harga.contains('Rp')) return harga;
    return 'Rp $harga';
  }

  String get gambarDisplay => gambarUrl ?? pathGambar;

  bool get isFromApi => gambarUrl != null && gambarUrl!.isNotEmpty;

  int get hargaInt {
    return int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  String toString() {
    return 'BarangJualanModel(id: $id, nama: $namaBarang, harga: $harga)';
  }
}