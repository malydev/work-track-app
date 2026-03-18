import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_track/core/storage/hive_boxes.dart';
import 'package:work_track/features/attendance/data/models/attendance_record_model.dart';
import 'package:work_track/features/settings/data/models/app_settings_model.dart';
import 'package:work_track/features/user/data/models/user_profile_model.dart';

abstract final class HiveInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(AppThemeModeAdapter().typeId)) {
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkScheduleModelAdapter().typeId)) {
      Hive.registerAdapter(WorkScheduleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppSettingsModelAdapter().typeId)) {
      Hive.registerAdapter(AppSettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(UserProfileModelAdapter().typeId)) {
      Hive.registerAdapter(UserProfileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AttendanceRecordModelAdapter().typeId)) {
      Hive.registerAdapter(AttendanceRecordModelAdapter());
    }
  }

  static Future<void> _openBoxes() async {
    if (!Hive.isBoxOpen(HiveBoxes.appSettings)) {
      await Hive.openBox<AppSettingsModel>(HiveBoxes.appSettings);
    }
    if (!Hive.isBoxOpen(HiveBoxes.userProfile)) {
      await Hive.openBox<UserProfileModel>(HiveBoxes.userProfile);
    }
    if (!Hive.isBoxOpen(HiveBoxes.attendanceRecords)) {
      await Hive.openBox<AttendanceRecordModel>(HiveBoxes.attendanceRecords);
    }
  }
}
