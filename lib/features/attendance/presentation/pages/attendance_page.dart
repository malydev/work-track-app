import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/theme/app_colors.dart';
import 'package:work_track/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:work_track/shared/providers/app_providers.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final attendanceState = ref.watch(attendanceControllerProvider);
    final attendanceAsync = ref.watch(attendanceHistoryProvider);
    final todayRecord =
        attendanceAsync.asData?.value.isNotEmpty == true
            ? attendanceAsync.asData!.value.first
            : null;

    ref.listen(attendanceControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
        children: [
          Text(
            'Marcado diario',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Una vista limpia para registrar tu jornada y ver el estado del dia.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primary.withValues(alpha: 0.82),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.32),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoy',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  todayRecord == null
                      ? 'Listo para registrar tu primera marcacion'
                      : todayRecord.checkOutAt == null
                      ? 'Entrada registrada. Falta salida.'
                      : 'Jornada completa registrada.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoChip(
                      label: 'Entrada',
                      value:
                          todayRecord == null
                              ? '--:--'
                              : _formatTime(todayRecord.checkInAt),
                      foreground: colors.onPrimary,
                    ),
                    _InfoChip(
                      label: 'Salida',
                      value:
                          todayRecord?.checkOutAt == null
                              ? '--:--'
                              : _formatTime(todayRecord!.checkOutAt!),
                      foreground: colors.onPrimary,
                    ),
                    _InfoChip(
                      label: 'Retraso',
                      value: '${todayRecord?.lateArrivalMinutes ?? 0} min',
                      foreground: colors.onPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            attendanceState.isSubmitting
                                ? null
                                : () =>
                                    ref
                                        .read(
                                          attendanceControllerProvider.notifier,
                                        )
                                        .registerCheckIn(),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.onPrimary,
                          foregroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Marcar entrada'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            attendanceState.isSubmitting
                                ? null
                                : () =>
                                    ref
                                        .read(
                                          attendanceControllerProvider.notifier,
                                        )
                                        .registerCheckOut(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.onPrimary,
                          side: BorderSide(
                            color: colors.onPrimary.withValues(alpha: 0.36),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Marcar salida'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Este mes',
                  value: '${attendanceAsync.asData?.value.length ?? 0}',
                  caption: 'registros',
                  tone: colors.surface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Promedio retraso',
                  value: _averageDelay(
                    attendanceAsync.asData?.value ?? const [],
                  ),
                  caption: 'minutos',
                  tone: colors.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Actividad reciente',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (attendanceAsync.asData?.value.isEmpty ?? true)
            _EmptyPanel(
              icon: Icons.event_busy_rounded,
              title: 'Sin marcaciones todavia',
              subtitle: 'Cuando registres tu primera jornada, aparecera aqui.',
            )
          else
            ...attendanceAsync.asData!.value
                .take(3)
                .map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecentRecordCard(record: record),
                  ),
                ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _averageDelay(List<dynamic> records) {
    if (records.isEmpty) {
      return '0';
    }

    final total = records.fold<int>(
      0,
      (sum, record) => sum + record.lateArrivalMinutes as int,
    );

    return (total / records.length).round().toString();
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.tone,
  });

  final String title;
  final String value;
  final String caption;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.66),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordCard extends StatelessWidget {
  const _RecentRecordCard({required this.record});

  final dynamic record;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.access_time_filled_rounded,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.dateKey,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entrada ${AttendancePage._formatTime(record.checkInAt)}'
                  '${record.checkOutAt != null ? ' • Salida ${AttendancePage._formatTime(record.checkOutAt!)}' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${record.lateArrivalMinutes}m',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color:
                  record.lateArrivalMinutes > 0
                      ? colors.warning
                      : colors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}
