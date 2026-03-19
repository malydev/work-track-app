import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/theme/app_colors.dart';
import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/shared/providers/app_providers.dart';

class AttendanceHistoryPage extends ConsumerWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
        children: [
          Text(
            'Calendario laboral',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Consulta tus dias marcados, las salidas pendientes y el retraso acumulado.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: colors.border),
            ),
            child: historyAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const _CalendarEmptyState();
                }

                final summary = _buildSummary(records);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MiniMetric(
                          label: 'Completos',
                          value: '${summary.completed}',
                        ),
                        _MiniMetric(
                          label: 'Pendientes',
                          value: '${summary.pending}',
                        ),
                        _MiniMetric(
                          label: 'Retraso total',
                          value: '${summary.totalDelay}m',
                        ),
                      ],
                    ),
                  ],
                );
              },
              error: (_, _) => const _CalendarEmptyState(),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Registros',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          historyAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return const _CalendarEmptyState.compact();
              }

              return Column(
                children:
                    records
                        .map(
                          (record) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HistoryTile(record: record),
                          ),
                        )
                        .toList(),
              );
            },
            error: (_, _) => const _CalendarEmptyState.compact(),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  _HistorySummary _buildSummary(List<AttendanceRecord> records) {
    var completed = 0;
    var pending = 0;
    var totalDelay = 0;

    for (final record in records) {
      if (record.checkOutAt == null) {
        pending++;
      } else {
        completed++;
      }
      totalDelay += record.lateArrivalMinutes;
    }

    return _HistorySummary(
      completed: completed,
      pending: pending,
      totalDelay: totalDelay,
    );
  }
}

class _HistorySummary {
  const _HistorySummary({
    required this.completed,
    required this.pending,
    required this.totalDelay,
  });

  final int completed;
  final int pending;
  final int totalDelay;
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final AttendanceRecord record;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  record.checkOutAt == null
                      ? colors.warning.withValues(alpha: 0.14)
                      : colors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              record.checkOutAt == null
                  ? Icons.more_time_rounded
                  : Icons.task_alt_rounded,
              color:
                  record.checkOutAt == null ? colors.warning : colors.success,
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
                const SizedBox(height: 6),
                Text(
                  'Entrada ${_formatTime(record.checkInAt)}'
                  '${record.checkOutAt != null ? ' • Salida ${_formatTime(record.checkOutAt!)}' : ' • Salida pendiente'}',
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

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _CalendarEmptyState extends StatelessWidget {
  const _CalendarEmptyState() : compactMode = false;

  const _CalendarEmptyState.compact() : compactMode = true;

  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.all(compactMode ? 18 : 28),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_rounded, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            'Aun no hay historial disponible',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (!compactMode) ...[
            const SizedBox(height: 6),
            Text(
              'Registra tu primera entrada para empezar a llenar el calendario.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
