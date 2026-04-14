import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/theme/app_colors.dart';
import 'package:work_track/features/settings/domain/entities/app_settings.dart';
import 'package:work_track/features/settings/presentation/controllers/settings_controller.dart';
import 'package:work_track/features/user/presentation/controllers/user_profile_controller.dart';
import 'package:work_track/shared/constants/ui_constants.dart';
import 'package:work_track/shared/providers/app_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final profileAsync = ref.watch(currentUserProfileProvider);
    final settings = ref.watch(resolvedSettingsProvider);
    final controllerState = ref.watch(userProfileControllerProvider);
    final settingsControllerState = ref.watch(settingsControllerProvider);

    ref.listen(userProfileControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      if (next.lastSavedAt != null &&
          next.lastSavedAt != previous?.lastSavedAt) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Informacion del perfil actualizada.'),
            ),
          );
      }
    });

    ref.listen(settingsControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      if (next.lastSavedAt != null &&
          next.lastSavedAt != previous?.lastSavedAt) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Configuracion actualizada.')),
          );
      }
    });

    profileAsync.whenData((profile) {
      if (_nameController.text.isEmpty && profile != null) {
        _nameController.text = profile.displayName;
        _emailController.text = profile.email ?? '';
        _birthDate = profile.birthDate;
      }
    });

    return SafeArea(
      child: ListView(
        padding: UiSpacing.pagePadding,
        children: [
          Text(
            'Perfil',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: UiSpacing.sm),
          Text(
            'Administra tu informacion personal y revisa tu configuracion activa.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: UiSpacing.cardLargePadding,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(UiRadius.sheet),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: UiRadius.circleAvatar,
                  height: UiRadius.circleAvatar,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _nameController.text.isEmpty
                      ? 'Usuario'
                      : _nameController.text,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: UiSpacing.xs),
                Text(
                  _emailController.text.isEmpty
                      ? 'Sin correo registrado'
                      : _emailController.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: UiSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: UiSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(UiRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake_rounded, color: colors.primary),
                      const SizedBox(width: UiSpacing.md),
                      Expanded(
                        child: Text(
                          _birthDate == null
                              ? 'Cumpleanos sin registrar'
                              : 'Cumpleanos: ${_formatDate(_birthDate!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Configuracion activa',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: UiSpacing.xl),
          Wrap(
            spacing: UiSpacing.lg,
            runSpacing: UiSpacing.lg,
            children: [
              _ProfileStat(label: 'Region', value: settings.regionCode ?? '--'),
              _ProfileStat(
                label: 'Zona horaria',
                value: settings.timeZoneId ?? '--',
              ),
              _ProfileStat(
                label: 'Horario entrada',
                value:
                    settings.workSchedule == null
                        ? '--'
                        : _formatMinutes(
                          settings.workSchedule!.expectedCheckInMinutes,
                        ),
              ),
              _ProfileStat(
                label: 'Dias',
                value:
                    settings.workSchedule == null
                        ? '--'
                        : '${settings.workSchedule!.workingDays.length} activos',
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.cardLg),
          Text(
            'Menu de ajustes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: UiSpacing.xl),
          _ProfileMenuTile(
            icon: Icons.palette_rounded,
            title: 'Color y apariencia',
            subtitle: _themeModeLabel(settings.themeMode),
            onTap: () => _showThemeSheet(settings.themeMode),
          ),
          const SizedBox(height: UiSpacing.lg),
          _ProfileMenuTile(
            icon: Icons.manage_accounts_rounded,
            title: 'Actualizar informacion',
            subtitle:
                controllerState.isSaving
                    ? 'Guardando cambios...'
                    : 'Editar nombre, correo y cumpleanos',
            onTap:
                controllerState.isSaving ? null : () => _showEditProfileSheet(),
          ),
          const SizedBox(height: UiSpacing.lg),
          _ProfileMenuTile(
            icon: Icons.schedule_rounded,
            title: 'Preferencias de jornada',
            subtitle:
                settings.workSchedule == null
                    ? 'Sin horario definido'
                    : '${_formatMinutes(settings.workSchedule!.expectedCheckInMinutes)}'
                        '${settings.workSchedule!.expectedCheckOutMinutes != null ? ' • ${_formatMinutes(settings.workSchedule!.expectedCheckOutMinutes!)}' : ''}',
            onTap: () => _showWorkScheduleSheet(settings),
          ),
          const SizedBox(height: UiSpacing.lg),
          _ProfileMenuTile(
            icon: Icons.public_rounded,
            title: 'Region y zona horaria',
            subtitle:
                '${settings.regionCode ?? '--'} • ${settings.timeZoneId ?? '--'}',
            onTap:
                settingsControllerState.isSaving
                    ? null
                    : () => _showRegionSheet(settings),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() {
    return ref
        .read(userProfileControllerProvider.notifier)
        .upsertProfile(
          id: 'local-user',
          displayName:
              _nameController.text.trim().isEmpty
                  ? 'Usuario'
                  : _nameController.text.trim(),
          email:
              _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
          birthDate: _birthDate,
        );
  }

  Future<void> _showThemeSheet(AppThemeMode currentMode) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var selectedMode = currentMode;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colors = context.appColors;

            Widget option(AppThemeMode mode, String label, IconData icon) {
              final selected = selectedMode == mode;

              return Padding(
                padding: const EdgeInsets.only(bottom: UiSpacing.lg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(UiRadius.xl),
                  onTap: () async {
                    setSheetState(() => selectedMode = mode);
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .updateThemeMode(mode);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: UiSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? colors.primary.withValues(alpha: 0.12)
                              : colors.surface,
                      borderRadius: BorderRadius.circular(UiRadius.xl),
                      border: Border.all(
                        color: selected ? colors.primary : colors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: selected ? colors.primary : colors.onSurface,
                        ),
                        const SizedBox(width: UiSpacing.xl),
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_rounded, color: colors.primary),
                      ],
                    ),
                  ),
                ),
              );
            }

            return _MenuSheet(
              title: 'Color y apariencia',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  option(
                    AppThemeMode.system,
                    'Segun el sistema',
                    Icons.brightness_auto_rounded,
                  ),
                  option(
                    AppThemeMode.light,
                    'Modo claro',
                    Icons.light_mode_rounded,
                  ),
                  option(
                    AppThemeMode.dark,
                    'Modo oscuro',
                    Icons.dark_mode_rounded,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showWorkScheduleSheet(AppSettings settings) async {
    final existing = settings.workSchedule;
    TimeOfDay? checkIn = _timeOfDayFromMinutes(
      existing?.expectedCheckInMinutes ?? (8 * 60),
    );
    TimeOfDay? checkOut =
        existing?.expectedCheckOutMinutes == null
            ? null
            : _timeOfDayFromMinutes(existing!.expectedCheckOutMinutes!);
    final workingDays = ValueNotifier<List<WorkDay>>(
      List<WorkDay>.from(
        existing?.workingDays ?? WorkSchedule.defaultWorkingDays,
      ),
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = context.appColors;

        return _MenuSheet(
          title: 'Preferencias de jornada',
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hora de entrada',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await _pickTime(
                        initialTime:
                            checkIn ?? const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        setSheetState(() => checkIn = picked);
                      }
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: Text(
                      checkIn == null
                          ? 'Seleccionar hora'
                          : _formatTimeOfDay(checkIn!),
                    ),
                  ),
                  const SizedBox(height: UiSpacing.card),
                  Text(
                    'Hora de salida',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await _pickTime(
                              initialTime:
                                  checkOut ??
                                  const TimeOfDay(hour: 17, minute: 0),
                            );
                            if (picked != null) {
                              setSheetState(() => checkOut = picked);
                            }
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(
                            checkOut == null
                                ? 'Opcional'
                                : _formatTimeOfDay(checkOut!),
                          ),
                        ),
                      ),
                      const SizedBox(width: UiSpacing.sm),
                      IconButton.outlined(
                        onPressed:
                            checkOut == null
                                ? null
                                : () => setSheetState(() => checkOut = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: UiSpacing.card),
                  Text(
                    'Dias laborables',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  ValueListenableBuilder<List<WorkDay>>(
                    valueListenable: workingDays,
                    builder: (context, days, _) {
                      return Wrap(
                        spacing: UiSpacing.sm,
                        runSpacing: UiSpacing.sm,
                        children:
                            WorkDay.values.map((day) {
                              final selected = days.contains(day);
                              return FilterChip(
                                label: Text(_workDayLabel(day)),
                                selected: selected,
                                onSelected: (value) {
                                  final next = List<WorkDay>.from(days);
                                  if (value) {
                                    next.add(day);
                                  } else {
                                    next.remove(day);
                                  }
                                  workingDays.value = next;
                                },
                                selectedColor: colors.primary.withValues(
                                  alpha: 0.14,
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: UiSpacing.card),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final days = workingDays.value;
                        if (days.isEmpty || checkIn == null) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Define hora de entrada y al menos un dia laboral.',
                                ),
                              ),
                            );
                          return;
                        }

                        await ref
                            .read(settingsControllerProvider.notifier)
                            .updateWorkSchedule(
                              WorkSchedule(
                                expectedCheckInMinutes: _minutesFromTimeOfDay(
                                  checkIn!,
                                ),
                                expectedCheckOutMinutes:
                                    checkOut == null
                                        ? null
                                        : _minutesFromTimeOfDay(checkOut!),
                                workingDays: days,
                              ),
                            );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: UiSpacing.buttonPadding,
                      ),
                      child: const Text('Guardar jornada'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    workingDays.dispose();
  }

  Future<void> _showEditProfileSheet() async {
    final nameController = TextEditingController(text: _nameController.text);
    final emailController = TextEditingController(text: _emailController.text);
    DateTime? birthDate = _birthDate;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _MenuSheet(
              title: 'Actualizar informacion',
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                    ),
                    const SizedBox(height: UiSpacing.lg),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electronico',
                      ),
                    ),
                    const SizedBox(height: UiSpacing.lg),
                    InkWell(
                      borderRadius: BorderRadius.circular(UiRadius.md),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          initialDate: birthDate ?? DateTime(2000),
                        );
                        if (picked != null) {
                          setSheetState(() => birthDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Cumpleanos',
                        ),
                        child: Text(
                          birthDate == null
                              ? 'Seleccionar fecha'
                              : _formatDate(birthDate!),
                        ),
                      ),
                    ),
                    const SizedBox(height: UiSpacing.card),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          _nameController.text = nameController.text;
                          _emailController.text = emailController.text;
                          setState(() => _birthDate = birthDate);
                          await _saveProfile();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: UiSpacing.buttonPadding,
                        ),
                        child: const Text('Guardar informacion'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _showRegionSheet(AppSettings settings) async {
    final useDeviceLocale = ValueNotifier(settings.useDeviceLocale);
    final useDeviceTimeZone = ValueNotifier(settings.useDeviceTimeZone);
    final timeZoneController = TextEditingController(
      text: settings.timeZoneId ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _MenuSheet(
          title: 'Region y zona horaria',
          child: ValueListenableBuilder<bool>(
            valueListenable: useDeviceLocale,
            builder: (context, localeValue, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: useDeviceTimeZone,
                builder: (context, timeZoneValue, __) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile.adaptive(
                        value: localeValue,
                        onChanged: (value) => useDeviceLocale.value = value,
                        title: const Text('Usar region del dispositivo'),
                      ),
                      SwitchListTile.adaptive(
                        value: timeZoneValue,
                        onChanged: (value) => useDeviceTimeZone.value = value,
                        title: const Text('Usar zona horaria del dispositivo'),
                      ),
                      const SizedBox(height: UiSpacing.sm),
                      TextField(
                        controller: timeZoneController,
                        enabled: !timeZoneValue,
                        decoration: const InputDecoration(
                          labelText: 'Zona horaria manual',
                          hintText: 'Ejemplo: America/La_Paz',
                        ),
                      ),
                      const SizedBox(height: UiSpacing.card),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            final manualTimeZone =
                                timeZoneController.text.trim();

                            await ref
                                .read(settingsControllerProvider.notifier)
                                .updateLocalization(
                                  useDeviceLocale: useDeviceLocale.value,
                                  useDeviceTimeZone: useDeviceTimeZone.value,
                                  timeZoneId:
                                      useDeviceTimeZone.value
                                          ? settings.timeZoneId
                                          : (manualTimeZone.isEmpty
                                              ? settings.timeZoneId
                                              : manualTimeZone),
                                );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: UiSpacing.buttonPadding,
                          ),
                          child: const Text('Guardar preferencias'),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );

    useDeviceLocale.dispose();
    useDeviceTimeZone.dispose();
    timeZoneController.dispose();
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String _formatMinutes(int totalMinutes) {
    final hour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minute = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _timeOfDayFromMinutes(int totalMinutes) {
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  int _minutesFromTimeOfDay(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  Future<TimeOfDay?> _pickTime({required TimeOfDay initialTime}) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  String _themeModeLabel(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => 'Segun el sistema',
      AppThemeMode.light => 'Modo claro',
      AppThemeMode.dark => 'Modo oscuro',
    };
  }

  String _workDayLabel(WorkDay day) {
    return switch (day) {
      WorkDay.monday => 'Lun',
      WorkDay.tuesday => 'Mar',
      WorkDay.wednesday => 'Mie',
      WorkDay.thursday => 'Jue',
      WorkDay.friday => 'Vie',
      WorkDay.saturday => 'Sab',
      WorkDay.sunday => 'Dom',
    };
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(UiSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(UiRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(height: UiSpacing.sm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(UiRadius.card),
      onTap: onTap,
      child: Container(
        padding: UiSpacing.cardPadding,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(UiRadius.card),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(UiRadius.sm),
              ),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: UiSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.xxs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurface.withValues(alpha: 0.56),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiSpacing.section,
        0,
        UiSpacing.section,
        UiSpacing.section,
      ),
      child: Container(
        padding: UiSpacing.cardLargePadding,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(UiRadius.sheet),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: UiSpacing.card),
            child,
          ],
        ),
      ),
    );
  }
}
