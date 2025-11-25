class CartModel {
  int? id;
  int? userId;
  String? idProduk;
  int? jumlah;

  CartModel({
    this.id,
    this.userId,
    this.idProduk,
    this.jumlah,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'id_produk': idProduk,
      'jumlah': jumlah,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      idProduk: map['id_produk'] as String?,
      jumlah: map['jumlah'] as int?,
    );
  }

  CartModel copy({
    int? id,
    int? userId,
    String? idProduk,
    int? jumlah,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      idProduk: idProduk ?? this.idProduk,
      jumlah: jumlah ?? this.jumlah,
    );
  }
}