import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:work_track/features/attendance/domain/usecases/calculate_late_arrival.dart';
import 'package:work_track/features/settings/domain/entities/app_settings.dart';

class RegisterCheckIn {
  const RegisterCheckIn(this._repository, this._calculateLateArrival);

  final AttendanceRepository _repository;
  final CalculateLateArrival _calculateLateArrival;

  Future<AttendanceRecord> call({
    required DateTime now,
    required AppSettings settings,
    String? userId,
    String? notes,
  }) async {
    final dateKey = _dateKey(now);
    final existing = _repository.getRecordByDateKey(dateKey, userId: userId);
    if (existing != null) {
      return existing;
    }

    final record = AttendanceRecord(
      id: '${userId ?? 'anonymous'}-$dateKey',
      dateKey: dateKey,
      checkInAt: now,
      userId: userId,
      notes: notes,
      lateArrivalMinutes: _calculateLateArrival(
        checkInAt: now,
        settings: settings,
      ),
      updatedAt: now,
    );

    await _repository.saveRecord(record);
    return record;
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
