class TransaksiModel {
  int? id;
  String? idTransaksi;
  int? userId;
  String? tanggalTransaksi;  // String in database
  double? totalHarga;
  double? ongkir;
  String? status;
  String? metodePembayaran;
  String? alamatPengiriman;
  List<ItemTransaksi>? items;

  TransaksiModel({
    this.id,
    this.idTransaksi,
    this.userId,
    this.tanggalTransaksi,
    this.totalHarga,
    this.ongkir,
    this.status,
    this.metodePembayaran,
    this.alamatPengiriman,
    this.items,
  });

  double get grandTotal => (totalHarga ?? 0) + (ongkir ?? 0);
  
  // Helper to get DateTime from String
  DateTime? get tanggalDateTime {
    if (tanggalTransaksi == null) return null;
    try {
      return DateTime.parse(tanggalTransaksi!);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_transaksi': idTransaksi,
      'user_id': userId,
      'tanggal_transaksi': tanggalTransaksi,
      'total_harga': totalHarga,
      'ongkir': ongkir,
      'status': status,
      'metode_pembayaran': metodePembayaran,
      'alamat_pengiriman': alamatPengiriman,
    };
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as int?,
      idTransaksi: map['id_transaksi'] as String?,
      userId: map['user_id'] as int?,
      tanggalTransaksi: map['tanggal_transaksi'] as String?,
      totalHarga: map['total_harga'] as double?,
      ongkir: map['ongkir'] as double?,
      status: map['status'] as String?,
      metodePembayaran: map['metode_pembayaran'] as String?,
      alamatPengiriman: map['alamat_pengiriman'] as String?,
    );
  }

  TransaksiModel copy({
    int? id,
    String? idTransaksi,
    int? userId,
    String? tanggalTransaksi,
    double? totalHarga,
    double? ongkir,
    String? status,
    String? metodePembayaran,
    String? alamatPengiriman,
    List<ItemTransaksi>? items,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      userId: userId ?? this.userId,
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      totalHarga: totalHarga ?? this.totalHarga,
      ongkir: ongkir ?? this.ongkir,
      status: status ?? this.status,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      alamatPengiriman: alamatPengiriman ?? this.alamatPengiriman,
      items: items ?? this.items,
    );
  }
}

class ItemTransaksi {
  int? id;
  int? transaksiId;
  String? idProduk;
  String? namaProduk;
  String? brand;
  int? jumlah;
  double? harga;
  String? gambar;

  ItemTransaksi({
    this.id,
    this.transaksiId,
    this.idProduk,
    this.namaProduk,
    this.brand,
    this.jumlah,
    this.harga,
    this.gambar,
  });

  double get subtotal => (harga ?? 0) * (jumlah ?? 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaksi_id': transaksiId,
      'id_produk': idProduk,
      'nama_produk': namaProduk,
      'brand': brand,
      'jumlah': jumlah,
      'harga': harga,
      'gambar': gambar,
    };
  }

  factory ItemTransaksi.fromMap(Map<String, dynamic> map) {
    return ItemTransaksi(
      id: map['id'] as int?,
      transaksiId: map['transaksi_id'] as int?,
      idProduk: map['id_produk'] as String?,
      namaProduk: map['nama_produk'] as String?,
      brand: map['brand'] as String?,
      jumlah: map['jumlah'] as int?,
      harga: map['harga'] as double?,
      gambar: map['gambar'] as String?,
    );
  }

  ItemTransaksi copy({
    int? id,
    int? transaksiId,
    String? idProduk,
    String? namaProduk,
    String? brand,
    int? jumlah,
    double? harga,
    String? gambar,
  }) {
    return ItemTransaksi(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      idProduk: idProduk ?? this.idProduk,
      namaProduk: namaProduk ?? this.namaProduk,
      brand: brand ?? this.brand,
      jumlah: jumlah ?? this.jumlah,
      harga: harga ?? this.harga,
      gambar: gambar ?? this.gambar,
    );
  }
}