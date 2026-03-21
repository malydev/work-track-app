import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:work_track/app/theme/app_colors.dart';
import 'package:work_track/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:work_track/features/attendance/presentation/pages/attendance_page.dart';
import 'package:work_track/features/user/presentation/pages/profile_page.dart';
import 'package:work_track/shared/constants/ui_constants.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _currentIndex = 1;

  static const _pages = [
    AttendanceHistoryPage(),
    AttendancePage(),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: UiSpacing.navOuterPadding,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UiRadius.panel),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: UiEffects.navBlurSigma,
                    sigmaY: UiEffects.navBlurSigma,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: UiEffects.navSurfaceAlpha,
                      ),
                      borderRadius: BorderRadius.circular(UiRadius.panel),
                      border: Border.all(
                        color: colors.border.withValues(
                          alpha: UiEffects.navBorderAlpha,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: UiEffects.navShadowAlpha,
                          ),
                          blurRadius: UiEffects.navShadowBlur,
                          offset: UiEffects.navShadowOffset,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: UiSpacing.navInnerPadding,
                        child: Row(
                          children: [
                            _NavItem(
                              icon: Icons.fingerprint_rounded,
                              label: 'Calendario',
                              selected: _currentIndex == 0,
                              onTap: () => setState(() => _currentIndex = 0),
                            ),
                            _NavItem(
                              icon: Icons.calendar_month_rounded,

                              label: 'Marcar',
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
          ),
        ],
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
        borderRadius: BorderRadius.circular(UiRadius.xl),
        onTap: onTap,
        child: AnimatedContainer(
          duration: UiMotion.fast,
          curve: Curves.easeOutCubic,
          padding: UiSpacing.navItemPadding,
          decoration: BoxDecoration(
            color:
                selected
                    ? colors.primary.withValues(
                      alpha: UiEffects.navSelectedAlpha,
                    )
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(UiRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? colors.primary : colors.onSurface),
              const SizedBox(height: UiSpacing.xs),
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
