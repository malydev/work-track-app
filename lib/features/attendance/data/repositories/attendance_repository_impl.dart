import 'package:work_track/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:work_track/features/attendance/data/models/attendance_record_model.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._localDataSource);

  final AttendanceLocalDataSource _localDataSource;

  @override
  List<AttendanceRecordModel> getRecords() {
    return _localDataSource.getRecords();
  }

  @override
  AttendanceRecordModel? getRecordById(String id) {
    return _localDataSource.getRecordById(id);
  }

  @override
  AttendanceRecordModel? getRecordByDateKey(String dateKey, {String? userId}) {
    return _localDataSource.getRecordByDateKey(dateKey, userId: userId);
  }

  @override
  Future<void> saveRecord(AttendanceRecordModel record) {
    return _localDataSource.saveRecord(record);
  }

  @override
  Future<void> deleteRecord(String id) {
    return _localDataSource.deleteRecord(id);
  }

  @override
  Future<void> clearRecords() {
    return _localDataSource.clearRecords();
  }

  @override
  Stream<List<AttendanceRecordModel>> watchRecords() {
    return _localDataSource.watchRecords();
  }
}
