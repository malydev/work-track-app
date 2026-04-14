import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:work_track/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:work_track/features/attendance/domain/usecases/calculate_late_arrival.dart';
import 'package:work_track/features/attendance/domain/usecases/register_check_in.dart';
import 'package:work_track/features/attendance/domain/usecases/register_check_out.dart';
import 'package:work_track/features/attendance/domain/usecases/save_attendance_record.dart';
import 'package:work_track/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:work_track/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/features/settings/domain/repositories/settings_repository.dart';
import 'package:work_track/features/settings/domain/usecases/get_resolved_settings.dart';
import 'package:work_track/features/settings/domain/usecases/save_settings.dart';
import 'package:work_track/features/user/data/datasources/user_local_data_source.dart';
import 'package:work_track/features/user/data/repositories/user_repository_impl.dart';
import 'package:work_track/features/user/domain/entities/user_profile.dart';
import 'package:work_track/features/user/domain/repositories/user_repository.dart';
import 'package:work_track/features/user/domain/usecases/save_user_profile.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  return HiveSettingsLocalDataSource.fromHive();
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return HiveUserLocalDataSource.fromHive();
});

final attendanceLocalDataSourceProvider = Provider<AttendanceLocalDataSource>((
  ref,
) {
  return HiveAttendanceLocalDataSource.fromHive();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userLocalDataSourceProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceLocalDataSourceProvider));
});

final getResolvedSettingsUseCaseProvider = Provider<GetResolvedSettings>((ref) {
  return GetResolvedSettings(ref.watch(settingsRepositoryProvider));
});

final saveSettingsUseCaseProvider = Provider<SaveSettings>((ref) {
  return SaveSettings(ref.watch(settingsRepositoryProvider));
});

final saveUserProfileUseCaseProvider = Provider<SaveUserProfile>((ref) {
  return SaveUserProfile(ref.watch(userRepositoryProvider));
});

final calculateLateArrivalUseCaseProvider = Provider<CalculateLateArrival>((
  ref,
) {
  return const CalculateLateArrival();
});

final registerCheckInUseCaseProvider = Provider<RegisterCheckIn>((ref) {
  return RegisterCheckIn(
    ref.watch(attendanceRepositoryProvider),
    ref.watch(calculateLateArrivalUseCaseProvider),
  );
});

final registerCheckOutUseCaseProvider = Provider<RegisterCheckOut>((ref) {
  return RegisterCheckOut(ref.watch(attendanceRepositoryProvider));
});

final saveAttendanceRecordUseCaseProvider = Provider<SaveAttendanceRecord>((
  ref,
) {
  return SaveAttendanceRecord(ref.watch(attendanceRepositoryProvider));
});

final deviceLocaleProvider = Provider<Locale>((ref) {
  return PlatformDispatcher.instance.locale;
});

final deviceTimeZoneProvider = Provider<String>((ref) {
  return DateTime.now().timeZoneName;
});

final currentSettingsProvider = StreamProvider<AppSettings?>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

final resolvedSettingsProvider = Provider<AppSettings>((ref) {
  final locale = ref.watch(deviceLocaleProvider);
  final timeZoneId = ref.watch(deviceTimeZoneProvider);
  final currentSettingsAsync = ref.watch(currentSettingsProvider);
  final currentSettings = currentSettingsAsync.asData?.value;

  if (currentSettings != null) {
    return AppSettings(
      themeMode: currentSettings.themeMode,
      localeCode:
          currentSettings.useDeviceLocale
              ? locale.toLanguageTag()
              : (currentSettings.localeCode ?? locale.toLanguageTag()),
      regionCode:
          currentSettings.useDeviceLocale
              ? (locale.countryCode ?? locale.languageCode)
              : (currentSettings.regionCode ??
                  locale.countryCode ??
                  locale.languageCode),
      timeZoneId:
          currentSettings.useDeviceTimeZone
              ? timeZoneId
              : (currentSettings.timeZoneId ?? timeZoneId),
      useDeviceTheme: currentSettings.useDeviceTheme,
      useDeviceLocale: currentSettings.useDeviceLocale,
      useDeviceTimeZone: currentSettings.useDeviceTimeZone,
      workSchedule: currentSettings.workSchedule,
    );
  }

  return ref
      .watch(getResolvedSettingsUseCaseProvider)
      .call(
        fallbackLocaleCode: locale.toLanguageTag(),
        fallbackRegionCode: locale.countryCode ?? locale.languageCode,
        fallbackTimeZoneId: timeZoneId,
      );
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userRepositoryProvider).watchProfile();
});

final attendanceHistoryProvider = StreamProvider<List<AttendanceRecord>>((ref) {
  return ref.watch(attendanceRepositoryProvider).watchRecords();
});
