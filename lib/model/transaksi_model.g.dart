// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransaksiModelAdapter extends TypeAdapter<TransaksiModel> {
  @override
  final int typeId = 1;

  @override
  TransaksiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransaksiModel(
      idTransaksi: fields[0] as String?,
      idUser: fields[1] as String?,
      tanggalTransaksi: fields[2] as DateTime?,
      items: (fields[3] as List?)?.cast<ItemTransaksi>(),
      totalHarga: fields[4] as double?,
      status: fields[5] as String?,
      metodePembayaran: fields[6] as String?,
      alamatPengiriman: fields[7] as String?,
      ongkir: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TransaksiModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.idTransaksi)
      ..writeByte(1)
      ..write(obj.idUser)
      ..writeByte(2)
      ..write(obj.tanggalTransaksi)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.totalHarga)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.metodePembayaran)
      ..writeByte(7)
      ..write(obj.alamatPengiriman)
      ..writeByte(8)
      ..write(obj.ongkir);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransaksiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTransaksiAdapter extends TypeAdapter<ItemTransaksi> {
  @override
  final int typeId = 2;

  @override
  ItemTransaksi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemTransaksi(
      idProduk: fields[0] as String?,
      namaProduk: fields[1] as String?,
      jumlah: fields[2] as int?,
      harga: fields[3] as double?,
      gambar: fields[4] as String?,
      brand: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemTransaksi obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idProduk)
      ..writeByte(1)
      ..write(obj.namaProduk)
      ..writeByte(2)
      ..write(obj.jumlah)
      ..writeByte(3)
      ..write(obj.harga)
      ..writeByte(4)
      ..write(obj.gambar)
      ..writeByte(5)
      ..write(obj.brand);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTransaksiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
