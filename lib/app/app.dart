import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:work_track/app/responsive/app_breakpoints.dart';
import 'package:work_track/app/theme/app_theme.dart';
import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/shared/providers/app_providers.dart';
import 'package:work_track/shared/presentation/pages/app_home_page.dart';

class WorkTrackApp extends ConsumerWidget {
  const WorkTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(resolvedSettingsProvider);

    return MaterialApp(
      title: 'Work Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeModeFromSettings(settings.themeMode),
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: AppBreakpoints.items,
        );
      },
      home: const AppHomePage(),
    );
  }

  ThemeMode _themeModeFromSettings(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
