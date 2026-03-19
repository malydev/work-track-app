import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';

class RegisterCheckOut {
  const RegisterCheckOut(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceRecord?> call({
    required DateTime now,
    String? userId,
  }) async {
    final dateKey = _dateKey(now);
    final existing = _repository.getRecordByDateKey(dateKey, userId: userId);
    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(checkOutAt: now, updatedAt: now);

    await _repository.saveRecord(updated);
    return updated;
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
