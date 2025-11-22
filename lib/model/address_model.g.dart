// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressModelAdapter extends TypeAdapter<AddressModel> {
  @override
  final int typeId = 4;

  @override
  AddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressModel(
      idAddress: fields[0] as String?,
      idUser: fields[1] as String?,
      namaLengkap: fields[2] as String?,
      nomorTelepon: fields[3] as String?,
      alamatLengkap: fields[4] as String?,
      kota: fields[5] as String?,
      provinsi: fields[6] as String?,
      kodePos: fields[7] as String?,
      isPrimary: fields[8] as bool?,
      label: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AddressModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.idAddress)
      ..writeByte(1)
      ..write(obj.idUser)
      ..writeByte(2)
      ..write(obj.namaLengkap)
      ..writeByte(3)
      ..write(obj.nomorTelepon)
      ..writeByte(4)
      ..write(obj.alamatLengkap)
      ..writeByte(5)
      ..write(obj.kota)
      ..writeByte(6)
      ..write(obj.provinsi)
      ..writeByte(7)
      ..write(obj.kodePos)
      ..writeByte(8)
      ..write(obj.isPrimary)
      ..writeByte(9)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}