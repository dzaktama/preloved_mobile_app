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
  String pathGambar;
  int idPenjual;
  String tanggalUpload;

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
    required this.idPenjual,
    required this.tanggalUpload,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'id_penjual': idPenjual,
      'tanggal_upload': tanggalUpload,
    };
  }

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
      pathGambar: map['path_gambar'] as String,
      idPenjual: map['id_penjual'] as int,
      tanggalUpload: map['tanggal_upload'] as String,
    );
  }

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
    int? idPenjual,
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
      idPenjual: idPenjual ?? this.idPenjual,
      tanggalUpload: tanggalUpload ?? this.tanggalUpload,
    );
  }
}