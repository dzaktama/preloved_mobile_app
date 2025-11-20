// lib/models/product_model.dart

class ProductModel {
  final String namaBarang;
  final String ukuran;
  final String kondisi;
  final String brand;
  final String kategori;
  final String deskripsi;
  final String harga;
  final String bahan;
  final String kontakPenjual;
  final String lokasi;
  final String linkGambar;

  ProductModel({
    required this.namaBarang,
    required this.ukuran,
    required this.kondisi,
    required this.brand,
    required this.kategori,
    required this.deskripsi,
    required this.harga,
    required this.bahan,
    required this.kontakPenjual,
    required this.lokasi,
    required this.linkGambar,
  });

  // Generate ID unik berdasarkan kombinasi field
  String get id {
    // Kombinasi nama + brand + ukuran + harga untuk membuat ID unik
    String combined = '$namaBarang$brand$ukuran$harga'
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('.', '')
        .toLowerCase();
    
    // Atau gunakan hashCode untuk ID yang lebih pendek
    return combined.hashCode.abs().toString();
  }

  // Convert JSON to ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Normalize the image URL coming from API: trim whitespace, remove newlines,
    // and ensure it has an HTTP/HTTPS scheme when possible. This prevents
    // Image.network from failing silently when URLs contain extra chars or
    // are missing the scheme after refactoring/splitting code.
    String rawImage = (json['link_gambar'] ?? '').toString().trim();
    rawImage = rawImage.replaceAll('\n', '').replaceAll('\r', '');

    if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
      if (rawImage.startsWith('//')) {
        rawImage = 'https:$rawImage';
      } else {
        rawImage = 'https://$rawImage';
      }
    }

    return ProductModel(
      namaBarang: json['nama_barang'] ?? '',
      ukuran: json['ukuran'] ?? '',
      kondisi: json['kondisi'] ?? '',
      brand: json['brand'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'] ?? '',
      bahan: json['bahan'] ?? '',
      kontakPenjual: json['kontak_penjual'] ?? '',
      lokasi: json['lokasi'] ?? '',
      linkGambar: rawImage,
    );
  }

  // Convert ProductModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'nama_barang': namaBarang,
      'ukuran': ukuran,
      'kondisi': kondisi,
      'brand': brand,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'harga': harga,
      'bahan': bahan,
      'kontak_penjual': kontakPenjual,
      'lokasi': lokasi,
      'link_gambar': linkGambar,
    };
  }

  // Get price as integer (remove "Rp" and dots)
  int get hargaInt {
    try {
      return int.parse(harga.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      return 0;
    }
  }

  // Get formatted price
  String get hargaFormatted {
    return harga;
  }

  // Copy with method
  ProductModel copyWith({
    String? namaBarang,
    String? ukuran,
    String? kondisi,
    String? brand,
    String? kategori,
    String? deskripsi,
    String? harga,
    String? bahan,
    String? kontakPenjual,
    String? lokasi,
    String? linkGambar,
  }) {
    return ProductModel(
      namaBarang: namaBarang ?? this.namaBarang,
      ukuran: ukuran ?? this.ukuran,
      kondisi: kondisi ?? this.kondisi,
      brand: brand ?? this.brand,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      bahan: bahan ?? this.bahan,
      kontakPenjual: kontakPenjual ?? this.kontakPenjual,
      lokasi: lokasi ?? this.lokasi,
      linkGambar: linkGambar ?? this.linkGambar,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, namaBarang: $namaBarang, brand: $brand, harga: $harga, kategori: $kategori)';
  }

  // Override equality operators untuk memastikan produk yang sama memiliki ID yang sama
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Response Model
class ProductResponse {
  final List<ProductModel> dataBarang;

  ProductResponse({required this.dataBarang});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data_barang'] as List;
    List<ProductModel> products = list.map((i) => ProductModel.fromJson(i)).toList();
    
    return ProductResponse(dataBarang: products);
  }

  Map<String, dynamic> toJson() {
    return {
      'data_barang': dataBarang.map((product) => product.toJson()).toList(),
    };
  }
}