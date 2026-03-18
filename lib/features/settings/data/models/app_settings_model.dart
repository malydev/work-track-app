import 'package:hive/hive.dart';

class AppSettingsModel {
  const AppSettingsModel({
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
  final WorkScheduleModel? workSchedule;

  AppSettingsModel copyWith({
    AppThemeMode? themeMode,
    String? localeCode,
    String? regionCode,
    String? timeZoneId,
    bool? useDeviceTheme,
    bool? useDeviceLocale,
    bool? useDeviceTimeZone,
    WorkScheduleModel? workSchedule,
    bool clearWorkSchedule = false,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      regionCode: regionCode ?? this.regionCode,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      useDeviceTheme: useDeviceTheme ?? this.useDeviceTheme,
      useDeviceLocale: useDeviceLocale ?? this.useDeviceLocale,
      useDeviceTimeZone: useDeviceTimeZone ?? this.useDeviceTimeZone,
      workSchedule:
          clearWorkSchedule ? null : workSchedule ?? this.workSchedule,
    );
  }
}

enum AppThemeMode { system, light, dark }

class WorkScheduleModel {
  const WorkScheduleModel({
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

class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 1;

  @override
  AppThemeMode read(BinaryReader reader) {
    return AppThemeMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    writer.writeByte(obj.index);
  }
}

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 2;

  @override
  AppSettingsModel read(BinaryReader reader) {
    return AppSettingsModel(
      themeMode: reader.read() as AppThemeMode,
      localeCode: reader.read() as String?,
      regionCode: reader.read() as String?,
      timeZoneId: reader.read() as String?,
      useDeviceTheme: reader.read() as bool,
      useDeviceLocale: reader.read() as bool,
      useDeviceTimeZone: reader.read() as bool,
      workSchedule: reader.read() as WorkScheduleModel?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..write(obj.themeMode)
      ..write(obj.localeCode)
      ..write(obj.regionCode)
      ..write(obj.timeZoneId)
      ..write(obj.useDeviceTheme)
      ..write(obj.useDeviceLocale)
      ..write(obj.useDeviceTimeZone)
      ..write(obj.workSchedule);
  }
}

class WorkScheduleModelAdapter extends TypeAdapter<WorkScheduleModel> {
  @override
  final int typeId = 4;

  @override
  WorkScheduleModel read(BinaryReader reader) {
    final expectedCheckInMinutes = reader.readInt();
    final expectedCheckOutMinutes = reader.read() as int?;
    final workingDayIndexes = (reader.read() as List).cast<int>();

    return WorkScheduleModel(
      expectedCheckInMinutes: expectedCheckInMinutes,
      expectedCheckOutMinutes: expectedCheckOutMinutes,
      workingDays: [
        for (final index in workingDayIndexes) WorkDay.values[index],
      ],
    );
  }

  @override
  void write(BinaryWriter writer, WorkScheduleModel obj) {
    writer
      ..writeInt(obj.expectedCheckInMinutes)
      ..write(obj.expectedCheckOutMinutes)
      ..write(obj.workingDays.map((day) => day.index).toList());
  }
}
