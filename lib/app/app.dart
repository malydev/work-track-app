import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:work_track/app/responsive/app_breakpoints.dart';
import 'package:work_track/app/theme/app_theme.dart';
import 'package:work_track/shared/presentation/pages/app_home_page.dart';

class WorkTrackApp extends StatelessWidget {
  const WorkTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Work Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: AppBreakpoints.items,
        );
      },
      home: const AppHomePage(),
    );
  }
}
