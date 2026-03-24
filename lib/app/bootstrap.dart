import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/app.dart';
import 'package:work_track/core/storage/hive_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcherError: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };

  runApp(const ProviderScope(child: WorkTrackApp()));
}
