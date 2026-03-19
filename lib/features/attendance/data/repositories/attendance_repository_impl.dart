import 'package:work_track/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:work_track/features/attendance/data/mappers/attendance_record_mapper.dart';
import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._localDataSource);

  final AttendanceLocalDataSource _localDataSource;

  @override
  List<AttendanceRecord> getRecords() {
    return _localDataSource
        .getRecords()
        .map((record) => record.toEntity())
        .toList();
  }

  @override
  AttendanceRecord? getRecordById(String id) {
    return _localDataSource.getRecordById(id)?.toEntity();
  }

  @override
  AttendanceRecord? getRecordByDateKey(String dateKey, {String? userId}) {
    return _localDataSource
        .getRecordByDateKey(dateKey, userId: userId)
        ?.toEntity();
  }

  @override
  Future<void> saveRecord(AttendanceRecord record) {
    return _localDataSource.saveRecord(record.toModel());
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
  Stream<List<AttendanceRecord>> watchRecords() {
    return _localDataSource.watchRecords().map(
      (records) => records.map((record) => record.toEntity()).toList(),
    );
  }
}
