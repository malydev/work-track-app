import 'dart:async';

import 'package:hive/hive.dart';
import 'package:work_track/core/storage/hive_boxes.dart';
import 'package:work_track/features/settings/data/models/app_settings_model.dart';

abstract interface class SettingsLocalDataSource {
  AppSettingsModel? getSettings();
  AppSettingsModel getResolvedSettings({
    required String fallbackLocaleCode,
    required String fallbackRegionCode,
    required String fallbackTimeZoneId,
  });
  Future<void> saveSettings(AppSettingsModel settings);
  Future<void> clearSettings();
  Stream<AppSettingsModel?> watchSettings();
}

class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  HiveSettingsLocalDataSource(this._box);

  factory HiveSettingsLocalDataSource.fromHive() {
    return HiveSettingsLocalDataSource(
      Hive.box<AppSettingsModel>(HiveBoxes.appSettings),
    );
  }

  static const _settingsKey = 'current';

  final Box<AppSettingsModel> _box;

  @override
  AppSettingsModel? getSettings() {
    return _box.get(_settingsKey);
  }

  @override
  AppSettingsModel getResolvedSettings({
    required String fallbackLocaleCode,
    required String fallbackRegionCode,
    required String fallbackTimeZoneId,
  }) {
    final current = getSettings();

    return AppSettingsModel(
      themeMode: current?.themeMode ?? AppThemeMode.system,
      localeCode:
          current == null || current.useDeviceLocale
              ? fallbackLocaleCode
              : current.localeCode ?? fallbackLocaleCode,
      regionCode:
          current == null || current.useDeviceLocale
              ? fallbackRegionCode
              : current.regionCode ?? fallbackRegionCode,
      timeZoneId:
          current == null || current.useDeviceTimeZone
              ? fallbackTimeZoneId
              : current.timeZoneId ?? fallbackTimeZoneId,
      useDeviceTheme: current?.useDeviceTheme ?? true,
      useDeviceLocale: current?.useDeviceLocale ?? true,
      useDeviceTimeZone: current?.useDeviceTimeZone ?? true,
      workSchedule: current?.workSchedule,
    );
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) {
    return _box.put(_settingsKey, settings);
  }

  @override
  Future<void> clearSettings() {
    return _box.delete(_settingsKey);
  }

  @override
  Stream<AppSettingsModel?> watchSettings() async* {
    yield getSettings();
    yield* _box.watch(key: _settingsKey).map((_) => getSettings());
  }
}
