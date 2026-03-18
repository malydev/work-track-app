import 'package:hive/hive.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.displayName,
    this.email,
    this.birthDate,
    this.photoPath,
  });

  final String id;
  final String displayName;
  final String? email;
  final DateTime? birthDate;
  final String? photoPath;
}

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 3;

  @override
  UserProfileModel read(BinaryReader reader) {
    return UserProfileModel(
      id: reader.readString(),
      displayName: reader.readString(),
      email: reader.read() as String?,
      birthDate: reader.read() as DateTime?,
      photoPath: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.displayName)
      ..write(obj.email)
      ..write(obj.birthDate)
      ..write(obj.photoPath);
  }
}
