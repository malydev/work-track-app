import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:work_track/app/theme/app_colors.dart';
import 'package:work_track/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:work_track/features/attendance/presentation/pages/attendance_page.dart';
import 'package:work_track/features/user/presentation/pages/profile_page.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _currentIndex = 0;

  static const _pages = [
    AttendancePage(),
    AttendanceHistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.background,
                  colors.primary.withValues(alpha: 0.08),
                  colors.background,
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          IndexedStack(index: _currentIndex, children: _pages),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.border.withValues(alpha: 0.7)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.fingerprint_rounded,
                        label: 'Marcar',
                        selected: _currentIndex == 0,
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                      _NavItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Calendario',
                        selected: _currentIndex == 1,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Perfil',
                        selected: _currentIndex == 2,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected
                    ? colors.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? colors.primary : colors.onSurface),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colors.primary : colors.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
