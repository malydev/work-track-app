import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/features/settings/constants/settings_messages.dart';
import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/shared/providers/app_providers.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsControllerState>(
      SettingsController.new,
    );

class SettingsController extends Notifier<SettingsControllerState> {
  @override
  SettingsControllerState build() {
    return const SettingsControllerState();
  }

  Future<void> save(AppSettings settings) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await ref.read(saveSettingsUseCaseProvider).call(settings);
      state = state.copyWith(isSaving: false, lastSavedAt: DateTime.now());
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: SettingsMessages.saveError,
      );
    }
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final current = _currentSettings();
    await save(
      AppSettings(
        themeMode: themeMode,
        localeCode: current.localeCode,
        regionCode: current.regionCode,
        timeZoneId: current.timeZoneId,
        useDeviceTheme: current.useDeviceTheme,
        useDeviceLocale: current.useDeviceLocale,
        useDeviceTimeZone: current.useDeviceTimeZone,
        workSchedule: current.workSchedule,
      ),
    );
  }

  Future<void> updateLocalization({
    String? localeCode,
    String? regionCode,
    String? timeZoneId,
    bool? useDeviceLocale,
    bool? useDeviceTimeZone,
  }) async {
    final current = _currentSettings();
    await save(
      AppSettings(
        themeMode: current.themeMode,
        localeCode: localeCode ?? current.localeCode,
        regionCode: regionCode ?? current.regionCode,
        timeZoneId: timeZoneId ?? current.timeZoneId,
        useDeviceTheme: current.useDeviceTheme,
        useDeviceLocale: useDeviceLocale ?? current.useDeviceLocale,
        useDeviceTimeZone: useDeviceTimeZone ?? current.useDeviceTimeZone,
        workSchedule: current.workSchedule,
      ),
    );
  }

  Future<void> updateWorkSchedule(WorkSchedule? workSchedule) async {
    final current = _currentSettings();
    await save(
      AppSettings(
        themeMode: current.themeMode,
        localeCode: current.localeCode,
        regionCode: current.regionCode,
        timeZoneId: current.timeZoneId,
        useDeviceTheme: current.useDeviceTheme,
        useDeviceLocale: current.useDeviceLocale,
        useDeviceTimeZone: current.useDeviceTimeZone,
        workSchedule: workSchedule,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  AppSettings _currentSettings() {
    return ref.read(currentSettingsProvider).asData?.value ??
        ref.read(resolvedSettingsProvider);
  }
}

class SettingsControllerState {
  const SettingsControllerState({
    this.isSaving = false,
    this.errorMessage,
    this.lastSavedAt,
  });

  final bool isSaving;
  final String? errorMessage;
  final DateTime? lastSavedAt;

  SettingsControllerState copyWith({
    bool? isSaving,
    String? errorMessage,
    DateTime? lastSavedAt,
    bool clearError = false,
    bool clearLastSavedAt = false,
  }) {
    return SettingsControllerState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastSavedAt: clearLastSavedAt ? null : lastSavedAt ?? this.lastSavedAt,
    );
  }
}
