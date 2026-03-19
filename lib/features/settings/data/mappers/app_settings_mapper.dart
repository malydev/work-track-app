import 'package:work_track/features/settings/data/models/app_settings_model.dart'
    as model;
import 'package:work_track/features/settings/domain/entities/app_settings.dart'
    as entity;

extension AppSettingsModelMapper on model.AppSettingsModel {
  entity.AppSettings toEntity() {
    return entity.AppSettings(
      themeMode: themeMode.toEntity(),
      localeCode: localeCode,
      regionCode: regionCode,
      timeZoneId: timeZoneId,
      useDeviceTheme: useDeviceTheme,
      useDeviceLocale: useDeviceLocale,
      useDeviceTimeZone: useDeviceTimeZone,
      workSchedule: workSchedule?.toEntity(),
    );
  }
}

extension AppSettingsEntityMapper on entity.AppSettings {
  model.AppSettingsModel toModel() {
    return model.AppSettingsModel(
      themeMode: themeMode.toModel(),
      localeCode: localeCode,
      regionCode: regionCode,
      timeZoneId: timeZoneId,
      useDeviceTheme: useDeviceTheme,
      useDeviceLocale: useDeviceLocale,
      useDeviceTimeZone: useDeviceTimeZone,
      workSchedule: workSchedule?.toModel(),
    );
  }
}

extension AppThemeModeModelMapper on model.AppThemeMode {
  entity.AppThemeMode toEntity() {
    return entity.AppThemeMode.values[index];
  }
}

extension AppThemeModeEntityMapper on entity.AppThemeMode {
  model.AppThemeMode toModel() {
    return model.AppThemeMode.values[index];
  }
}

extension WorkScheduleModelMapper on model.WorkScheduleModel {
  entity.WorkSchedule toEntity() {
    return entity.WorkSchedule(
      expectedCheckInMinutes: expectedCheckInMinutes,
      expectedCheckOutMinutes: expectedCheckOutMinutes,
      workingDays: workingDays.map((day) => day.toEntity()).toList(),
    );
  }
}

extension WorkScheduleEntityMapper on entity.WorkSchedule {
  model.WorkScheduleModel toModel() {
    return model.WorkScheduleModel(
      expectedCheckInMinutes: expectedCheckInMinutes,
      expectedCheckOutMinutes: expectedCheckOutMinutes,
      workingDays: workingDays.map((day) => day.toModel()).toList(),
    );
  }
}

extension WorkDayModelMapper on model.WorkDay {
  entity.WorkDay toEntity() {
    return entity.WorkDay.values[index];
  }
}

extension WorkDayEntityMapper on entity.WorkDay {
  model.WorkDay toModel() {
    return model.WorkDay.values[index];
  }
}
