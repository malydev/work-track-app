import 'package:work_track/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  AppSettings? getSettings();
  AppSettings getResolvedSettings({
    required String fallbackLocaleCode,
    required String fallbackRegionCode,
    required String fallbackTimeZoneId,
  });
  Future<void> saveSettings(AppSettings settings);
  Future<void> clearSettings();
  Stream<AppSettings?> watchSettings();
}
