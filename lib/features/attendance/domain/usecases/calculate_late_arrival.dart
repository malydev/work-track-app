import 'package:work_track/features/settings/domain/entities/app_settings.dart';

class CalculateLateArrival {
  const CalculateLateArrival();

  int call({required DateTime checkInAt, required AppSettings settings}) {
    final schedule = settings.workSchedule;
    if (schedule == null) {
      return 0;
    }

    final weekday = _mapWeekday(checkInAt.weekday);
    if (!schedule.workingDays.contains(weekday)) {
      return 0;
    }

    final expectedMinutes = schedule.expectedCheckInMinutes;
    final actualMinutes = (checkInAt.hour * 60) + checkInAt.minute;

    if (actualMinutes <= expectedMinutes) {
      return 0;
    }

    return actualMinutes - expectedMinutes;
  }

  WorkDay _mapWeekday(int weekday) {
    return switch (weekday) {
      DateTime.monday => WorkDay.monday,
      DateTime.tuesday => WorkDay.tuesday,
      DateTime.wednesday => WorkDay.wednesday,
      DateTime.thursday => WorkDay.thursday,
      DateTime.friday => WorkDay.friday,
      DateTime.saturday => WorkDay.saturday,
      _ => WorkDay.sunday,
    };
  }
}
