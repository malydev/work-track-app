import 'package:work_track/features/attendance/data/models/attendance_record_model.dart'
    as model;
import 'package:work_track/features/attendance/domain/entities/attendance_record.dart'
    as entity;

extension AttendanceRecordModelMapper on model.AttendanceRecordModel {
  entity.AttendanceRecord toEntity() {
    return entity.AttendanceRecord(
      id: id,
      dateKey: dateKey,
      checkInAt: checkInAt,
      checkOutAt: checkOutAt,
      userId: userId,
      notes: notes,
      lateArrivalMinutes: lateArrivalMinutes,
      updatedAt: updatedAt,
    );
  }
}

extension AttendanceRecordEntityMapper on entity.AttendanceRecord {
  model.AttendanceRecordModel toModel() {
    return model.AttendanceRecordModel(
      id: id,
      dateKey: dateKey,
      checkInAt: checkInAt,
      checkOutAt: checkOutAt,
      userId: userId,
      notes: notes,
      lateArrivalMinutes: lateArrivalMinutes,
      updatedAt: updatedAt,
    );
  }
}
