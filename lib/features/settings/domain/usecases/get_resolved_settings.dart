import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/features/settings/domain/repositories/settings_repository.dart';

class GetResolvedSettings {
  const GetResolvedSettings(this._repository);

  final SettingsRepository _repository;

  AppSettings call({
    required String fallbackLocaleCode,
    required String fallbackRegionCode,
    required String fallbackTimeZoneId,
  }) {
    return _repository.getResolvedSettings(
      fallbackLocaleCode: fallbackLocaleCode,
      fallbackRegionCode: fallbackRegionCode,
      fallbackTimeZoneId: fallbackTimeZoneId,
    );
  }
}
