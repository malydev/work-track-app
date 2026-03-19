import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';

abstract interface class AttendanceRepository {
  List<AttendanceRecord> getRecords();
  AttendanceRecord? getRecordById(String id);
  AttendanceRecord? getRecordByDateKey(String dateKey, {String? userId});
  Future<void> saveRecord(AttendanceRecord record);
  Future<void> deleteRecord(String id);
  Future<void> clearRecords();
  Stream<List<AttendanceRecord>> watchRecords();
}
