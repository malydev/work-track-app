import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/features/settings/domain/repositories/settings_repository.dart';

class SaveSettings {
  const SaveSettings(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppSettings settings) {
    return _repository.saveSettings(settings);
  }
}
