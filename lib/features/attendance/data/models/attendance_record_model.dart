import 'package:hive/hive.dart';

class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.dateKey,
    required this.checkInAt,
    this.checkOutAt,
    this.userId,
    this.notes,
    this.lateArrivalMinutes = 0,
    this.updatedAt,
  });

  final String id;
  final String dateKey;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final String? userId;
  final String? notes;
  final int lateArrivalMinutes;
  final DateTime? updatedAt;

  AttendanceRecordModel copyWith({
    String? id,
    String? dateKey,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    String? userId,
    String? notes,
    int? lateArrivalMinutes,
    DateTime? updatedAt,
    bool clearCheckOutAt = false,
    bool clearNotes = false,
    bool clearUpdatedAt = false,
  }) {
    return AttendanceRecordModel(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: clearCheckOutAt ? null : checkOutAt ?? this.checkOutAt,
      userId: userId ?? this.userId,
      notes: clearNotes ? null : notes ?? this.notes,
      lateArrivalMinutes: lateArrivalMinutes ?? this.lateArrivalMinutes,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }
}

class AttendanceRecordModelAdapter extends TypeAdapter<AttendanceRecordModel> {
  @override
  final int typeId = 5;

  @override
  AttendanceRecordModel read(BinaryReader reader) {
    return AttendanceRecordModel(
      id: reader.readString(),
      dateKey: reader.readString(),
      checkInAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      checkOutAt: reader.read() as DateTime?,
      userId: reader.read() as String?,
      notes: reader.read() as String?,
      lateArrivalMinutes: reader.readInt(),
      updatedAt: reader.read() as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecordModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.dateKey)
      ..writeInt(obj.checkInAt.millisecondsSinceEpoch)
      ..write(obj.checkOutAt)
      ..write(obj.userId)
      ..write(obj.notes)
      ..writeInt(obj.lateArrivalMinutes)
      ..write(obj.updatedAt);
  }
}
