import 'package:work_track/features/attendance/data/models/attendance_record_model.dart';

abstract interface class AttendanceRepository {
  List<AttendanceRecordModel> getRecords();
  AttendanceRecordModel? getRecordById(String id);
  AttendanceRecordModel? getRecordByDateKey(String dateKey, {String? userId});
  Future<void> saveRecord(AttendanceRecordModel record);
  Future<void> deleteRecord(String id);
  Future<void> clearRecords();
  Stream<List<AttendanceRecordModel>> watchRecords();
}
