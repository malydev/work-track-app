import 'package:work_track/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:work_track/features/settings/data/mappers/app_settings_mapper.dart';
import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  AppSettings? getSettings() {
    return _localDataSource.getSettings()?.toEntity();
  }

  @override
  AppSettings getResolvedSettings({
    required String fallbackLocaleCode,
    required String fallbackRegionCode,
    required String fallbackTimeZoneId,
  }) {
    return _localDataSource
        .getResolvedSettings(
          fallbackLocaleCode: fallbackLocaleCode,
          fallbackRegionCode: fallbackRegionCode,
          fallbackTimeZoneId: fallbackTimeZoneId,
        )
        .toEntity();
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _localDataSource.saveSettings(settings.toModel());
  }

  @override
  Future<void> clearSettings() {
    return _localDataSource.clearSettings();
  }

  @override
  Stream<AppSettings?> watchSettings() {
    return _localDataSource.watchSettings().map(
      (settings) => settings?.toEntity(),
    );
  }
}
