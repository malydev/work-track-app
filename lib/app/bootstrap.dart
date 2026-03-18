import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/app.dart';
import 'package:work_track/core/storage/hive_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initialize();

  runApp(const ProviderScope(child: WorkTrackApp()));
}
