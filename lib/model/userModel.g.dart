// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uId: fields[0] as String?,
      uName: fields[1] as String?,
      uEmail: fields[2] as String?,
      uPassword: fields[3] as String?,
      uPhone: fields[4] as String?,
      uAddress: fields[5] as String?,
      uFotoProfil: fields[6] as String?,
      uRole: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uId)
      ..writeByte(1)
      ..write(obj.uName)
      ..writeByte(2)
      ..write(obj.uEmail)
      ..writeByte(3)
      ..write(obj.uPassword)
      ..writeByte(4)
      ..write(obj.uPhone)
      ..writeByte(5)
      ..write(obj.uAddress)
      ..writeByte(6)
      ..write(obj.uFotoProfil)
      ..writeByte(7)
      ..write(obj.uRole);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
