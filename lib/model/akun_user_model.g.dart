// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'akun_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AkunUserModelAdapter extends TypeAdapter<AkunUserModel> {
  @override
  final int typeId = 0;

  @override
  AkunUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AkunUserModel(
      username: fields[0] as String,
      email: fields[1] as String,
      password: fields[2] as String,
      noHp: fields[3] as String,
      fotoProfil: fields[4] as String,
      role: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AkunUserModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.noHp)
      ..writeByte(4)
      ..write(obj.fotoProfil)
      ..writeByte(5)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AkunUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
