import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:work_track/features/attendance/data/models/attendance_record_model.dart';
import 'package:work_track/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:work_track/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:work_track/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:work_track/features/settings/data/models/app_settings_model.dart';
import 'package:work_track/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:work_track/features/settings/domain/repositories/settings_repository.dart';
import 'package:work_track/features/user/data/datasources/user_local_data_source.dart';
import 'package:work_track/features/user/data/models/user_profile_model.dart';
import 'package:work_track/features/user/data/repositories/user_repository_impl.dart';
import 'package:work_track/features/user/domain/repositories/user_repository.dart';

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

final deviceLocaleProvider = Provider<Locale>((ref) {
  return PlatformDispatcher.instance.locale;
});

final deviceTimeZoneProvider = Provider<String>((ref) {
  return DateTime.now().timeZoneName;
});

final currentSettingsProvider = StreamProvider<AppSettingsModel?>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

final resolvedSettingsProvider = Provider<AppSettingsModel>((ref) {
  final locale = ref.watch(deviceLocaleProvider);
  final timeZoneId = ref.watch(deviceTimeZoneProvider);

  return ref
      .watch(settingsRepositoryProvider)
      .getResolvedSettings(
        fallbackLocaleCode: locale.toLanguageTag(),
        fallbackRegionCode: locale.countryCode ?? locale.languageCode,
        fallbackTimeZoneId: timeZoneId,
      );
});

final currentUserProfileProvider = StreamProvider<UserProfileModel?>((ref) {
  return ref.watch(userRepositoryProvider).watchProfile();
});

final attendanceHistoryProvider = StreamProvider<List<AttendanceRecordModel>>((
  ref,
) {
  return ref.watch(attendanceRepositoryProvider).watchRecords();
});
