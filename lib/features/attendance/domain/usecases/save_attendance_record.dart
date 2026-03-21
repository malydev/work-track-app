import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';

class SaveAttendanceRecord {
  const SaveAttendanceRecord(this._repository);

  final AttendanceRepository _repository;

  Future<void> call(AttendanceRecord record) {
    return _repository.saveRecord(record);
  }
}
