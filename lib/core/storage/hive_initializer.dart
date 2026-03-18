import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_track/core/storage/hive_boxes.dart';

abstract final class HiveInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isBoxOpen(HiveBoxes.appConfig)) {
      await Hive.openBox<dynamic>(HiveBoxes.appConfig);
    }
  }
}
