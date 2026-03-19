import 'package:work_track/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:work_track/features/settings/data/models/app_settings_model.dart';
import 'package:work_track/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  AppSettingsModel? getSettings() {
    return _localDataSource.getSettings();
  }

  @override
  AppSettingsModel getResolvedSettings({
    required String fallbackLocaleCode,
    required String fallbackRegionCode,
    required String fallbackTimeZoneId,
  }) {
    return _localDataSource.getResolvedSettings(
      fallbackLocaleCode: fallbackLocaleCode,
      fallbackRegionCode: fallbackRegionCode,
      fallbackTimeZoneId: fallbackTimeZoneId,
    );
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) {
    return _localDataSource.saveSettings(settings);
  }

  @override
  Future<void> clearSettings() {
    return _localDataSource.clearSettings();
  }

  @override
  Stream<AppSettingsModel?> watchSettings() {
    return _localDataSource.watchSettings();
  }
}
