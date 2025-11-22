import 'package:hive/hive.dart';

part 'cart_model.g.dart';

@HiveType(typeId: 3)
class CartModel extends HiveObject {
  @HiveField(0)
  String? idProduk;

  @HiveField(1)
  int? jumlah;

  CartModel({
    this.idProduk,
    this.jumlah,
  });
}