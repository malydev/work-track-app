import 'dart:async';

import 'package:hive/hive.dart';
import 'package:work_track/core/storage/hive_boxes.dart';
import 'package:work_track/features/attendance/data/models/attendance_record_model.dart';

abstract interface class AttendanceLocalDataSource {
  List<AttendanceRecordModel> getRecords();
  AttendanceRecordModel? getRecordById(String id);
  AttendanceRecordModel? getRecordByDateKey(String dateKey, {String? userId});
  Future<void> saveRecord(AttendanceRecordModel record);
  Future<void> deleteRecord(String id);
  Future<void> clearRecords();
  Stream<List<AttendanceRecordModel>> watchRecords();
}

class HiveAttendanceLocalDataSource implements AttendanceLocalDataSource {
  HiveAttendanceLocalDataSource(this._box);

  factory HiveAttendanceLocalDataSource.fromHive() {
    return HiveAttendanceLocalDataSource(
      Hive.box<AttendanceRecordModel>(HiveBoxes.attendanceRecords),
    );
  }

  final Box<AttendanceRecordModel> _box;

  @override
  List<AttendanceRecordModel> getRecords() {
    final records = _box.values.toList();
    records.sort((a, b) => b.checkInAt.compareTo(a.checkInAt));
    return records;
  }

  @override
  AttendanceRecordModel? getRecordById(String id) {
    return _box.get(id);
  }

  @override
  AttendanceRecordModel? getRecordByDateKey(String dateKey, {String? userId}) {
    for (final record in _box.values) {
      final isSameDate = record.dateKey == dateKey;
      final isSameUser = userId == null || record.userId == userId;

      if (isSameDate && isSameUser) {
        return record;
      }
    }

    return null;
  }

  @override
  Future<void> saveRecord(AttendanceRecordModel record) {
    return _box.put(record.id, record);
  }

  @override
  Future<void> deleteRecord(String id) {
    return _box.delete(id);
  }

  @override
  Future<void> clearRecords() {
    return _box.clear();
  }

  @override
  Stream<List<AttendanceRecordModel>> watchRecords() async* {
    yield getRecords();
    yield* _box.watch().map((_) => getRecords());
  }
}
