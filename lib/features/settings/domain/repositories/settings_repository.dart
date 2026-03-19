import 'package:work_track/features/settings/data/models/app_settings_model.dart';

abstract interface class SettingsRepository {
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
