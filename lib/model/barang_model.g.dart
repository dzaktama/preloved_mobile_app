// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barang_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarangJualanModelAdapter extends TypeAdapter<BarangJualanModel> {
  @override
  final int typeId = 1;

  @override
  BarangJualanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BarangJualanModel(
      namaBarang: fields[0] as String,
      harga: fields[1] as String,
      kategori: fields[2] as String,
      kondisi: fields[3] as String,
      ukuran: fields[4] as String,
      brand: fields[5] as String,
      bahan: fields[6] as String,
      deskripsi: fields[7] as String,
      lokasi: fields[8] as String,
      kontakPenjual: fields[9] as String,
      pathGambar: fields[10] as String,
      idPenjual: fields[11] as String,
      tanggalUpload: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BarangJualanModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.namaBarang)
      ..writeByte(1)
      ..write(obj.harga)
      ..writeByte(2)
      ..write(obj.kategori)
      ..writeByte(3)
      ..write(obj.kondisi)
      ..writeByte(4)
      ..write(obj.ukuran)
      ..writeByte(5)
      ..write(obj.brand)
      ..writeByte(6)
      ..write(obj.bahan)
      ..writeByte(7)
      ..write(obj.deskripsi)
      ..writeByte(8)
      ..write(obj.lokasi)
      ..writeByte(9)
      ..write(obj.kontakPenjual)
      ..writeByte(10)
      ..write(obj.pathGambar)
      ..writeByte(11)
      ..write(obj.idPenjual)
      ..writeByte(12)
      ..write(obj.tanggalUpload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarangJualanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
