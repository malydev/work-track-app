import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/theme/app_colors.dart';
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

    ref.listen(userProfileControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
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
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                ),
                const SizedBox(height: UiSpacing.xl),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electronico',
                  ),
                ),
                const SizedBox(height: UiSpacing.xl),
                InkWell(
                  borderRadius: BorderRadius.circular(UiRadius.md),
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Cumpleanos'),
                    child: Text(
                      _birthDate == null
                          ? 'Seleccionar fecha'
                          : _formatDate(_birthDate!),
                    ),
                  ),
                ),
                const SizedBox(height: UiSpacing.card),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controllerState.isSaving ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      padding: UiSpacing.buttonPadding,
                    ),
                    child: const Text('Guardar perfil'),
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
        ],
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: _birthDate ?? DateTime(2000),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
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
