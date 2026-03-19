class AppSettings {
  const AppSettings({
    required this.themeMode,
    this.localeCode,
    this.regionCode,
    this.timeZoneId,
    this.useDeviceTheme = true,
    this.useDeviceLocale = true,
    this.useDeviceTimeZone = true,
    this.workSchedule,
  });

  final AppThemeMode themeMode;
  final String? localeCode;
  final String? regionCode;
  final String? timeZoneId;
  final bool useDeviceTheme;
  final bool useDeviceLocale;
  final bool useDeviceTimeZone;
  final WorkSchedule? workSchedule;
}

enum AppThemeMode { system, light, dark }

class WorkSchedule {
  const WorkSchedule({
    required this.expectedCheckInMinutes,
    this.expectedCheckOutMinutes,
    this.workingDays = defaultWorkingDays,
  });

  final int expectedCheckInMinutes;
  final int? expectedCheckOutMinutes;
  final List<WorkDay> workingDays;

  static const List<WorkDay> defaultWorkingDays = [
    WorkDay.monday,
    WorkDay.tuesday,
    WorkDay.wednesday,
    WorkDay.thursday,
    WorkDay.friday,
  ];
}

enum WorkDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
