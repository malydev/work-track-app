import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/app/theme/app_colors.dart';
import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:work_track/shared/constants/ui_constants.dart';
import 'package:work_track/shared/providers/app_providers.dart';

class AttendanceHistoryPage extends ConsumerStatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  ConsumerState<AttendanceHistoryPage> createState() =>
      _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends ConsumerState<AttendanceHistoryPage> {
  final _eventController = EventController<AttendanceRecord>();
  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _lastSyncedRecords = const [];

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final historyAsync = ref.watch(attendanceHistoryProvider);

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
        padding: UiSpacing.pagePadding,
        children: [
          Text(
            'Calendario laboral',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: UiSpacing.sm),
          Text(
            'Consulta tus dias marcados, identifica jornadas pendientes y agrega notas por fecha.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: UiSpacing.cardLg),
          historyAsync.when(
            data: (records) {
              _syncEvents(records);

              return Column(
                children: [
                  _SummaryPanel(records: records),
                  const SizedBox(height: UiSpacing.cardLg),
                  Container(
                    padding: UiSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(UiRadius.sheet),
                      border: Border.all(color: colors.border),
                    ),
                    child: CalendarControllerProvider<AttendanceRecord>(
                      controller: _eventController,
                      child: MonthView<AttendanceRecord>(
                        monthViewThemeSettings: MonthViewThemeSettings(
                          weekDayTextStyle: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w700,
                          ),
                          textStyle: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          headerStyle: HeaderStyle(
                            headerTextStyle: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          cellsInMonthHighlightColor: colors.primary,
                          cellsInMonthHighlightedTitleColor: colors.onPrimary,
                        ),
                        monthViewStyle: MonthViewStyle(
                          initialMonth: _selectedDate,
                          cellAspectRatio: 1.05,
                          showBorder: false,
                          showWeekTileBorder: false,
                          hideDaysNotInMonth: false,
                          startDay: WeekDays.monday,
                        ),
                        monthViewBuilders: MonthViewBuilders<AttendanceRecord>(
                          weekDayStringBuilder: _weekDayLabel,
                          cellBuilder: (
                            date,
                            events,
                            isToday,
                            isInMonth,
                            hideDaysNotInMonth,
                          ) {
                            final record =
                                events.isEmpty ? null : events.first.event;
                            return _CalendarCell(
                              date: date,
                              isToday: isToday,
                              isInMonth: isInMonth,
                              record: record,
                              onTap: () => setState(() => _selectedDate = date),
                            );
                          },
                          onCellTap: (events, date) {
                            setState(() => _selectedDate = date);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: UiSpacing.cardLg),
                  _SelectedDayPanel(
                    selectedDate: _selectedDate,
                    record: _recordForSelectedDate(records),
                    onAddNote:
                        _recordForSelectedDate(records) == null
                            ? null
                            : () => _showNoteSheet(
                              _recordForSelectedDate(records)!,
                            ),
                  ),
                ],
              );
            },
            error: (_, _) => const _CalendarEmptyState(),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  void _syncEvents(List<AttendanceRecord> records) {
    if (_sameRecords(records, _lastSyncedRecords)) {
      return;
    }

    _eventController.removeAll(_eventController.allEvents);

    for (final record in records) {
      _eventController.add(
        CalendarEventData<AttendanceRecord>(
          date: DateTime(
            record.checkInAt.year,
            record.checkInAt.month,
            record.checkInAt.day,
          ),
          title: record.notes?.isNotEmpty == true ? 'Con nota' : 'Marcado',
          description: record.notes,
          color:
              record.checkOutAt == null
                  ? context.appColors.warning
                  : context.appColors.success,
          event: record,
        ),
      );
    }

    _lastSyncedRecords = List<AttendanceRecord>.from(records);
  }

  bool _sameRecords(
    List<AttendanceRecord> current,
    List<AttendanceRecord> previous,
  ) {
    if (identical(current, previous)) {
      return true;
    }
    if (current.length != previous.length) {
      return false;
    }

    for (var index = 0; index < current.length; index++) {
      if (current[index].id != previous[index].id ||
          current[index].updatedAt != previous[index].updatedAt ||
          current[index].notes != previous[index].notes ||
          current[index].checkOutAt != previous[index].checkOutAt) {
        return false;
      }
    }

    return true;
  }

  AttendanceRecord? _recordForSelectedDate(List<AttendanceRecord> records) {
    final key = _dateKey(_selectedDate);
    for (final record in records) {
      if (record.dateKey == key) {
        return record;
      }
    }
    return null;
  }

  Future<void> _showNoteSheet(AttendanceRecord record) async {
    final controller = TextEditingController(text: record.notes ?? '');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = context.appColors;

        return Padding(
          padding: EdgeInsets.only(
            left: UiSpacing.section,
            right: UiSpacing.section,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + UiSpacing.section,
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
                  'Nota del dia',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: UiSpacing.sm),
                Text(
                  record.dateKey,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: UiSpacing.card),
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Escribe una nota para esta fecha',
                  ),
                ),
                const SizedBox(height: UiSpacing.card),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await ref
                          .read(attendanceControllerProvider.notifier)
                          .saveNote(record: record, note: controller.text);

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: UiSpacing.buttonPadding,
                    ),
                    child: const Text('Guardar nota'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _weekDayLabel(int day) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return labels[day];
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.records});

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final completed =
        records.where((record) => record.checkOutAt != null).length;
    final pending = records.length - completed;
    final totalDelay = records.fold<int>(
      0,
      (sum, record) => sum + record.lateArrivalMinutes,
    );

    return Container(
      padding: const EdgeInsets.all(UiSpacing.section),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(UiRadius.sheet),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: UiSpacing.lg,
        runSpacing: UiSpacing.lg,
        children: [
          _MiniMetric(label: 'Completos', value: '$completed'),
          _MiniMetric(label: 'Pendientes', value: '$pending'),
          _MiniMetric(label: 'Retraso total', value: '${totalDelay}m'),
        ],
      ),
    );
  }
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
      padding: const EdgeInsets.all(UiSpacing.xl),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UiRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: UiSpacing.sm),
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

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.date,
    required this.isToday,
    required this.isInMonth,
    required this.record,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isInMonth;
  final AttendanceRecord? record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasRecord = record != null;
    final tone =
        hasRecord
            ? record!.checkOutAt == null
                ? colors.warning
                : colors.success
            : colors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              hasRecord
                  ? tone.withValues(alpha: 0.18)
                  : isToday
                  ? colors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(UiRadius.md),
          border: Border.all(
            color:
                hasRecord
                    ? tone.withValues(alpha: 0.5)
                    : colors.border.withValues(alpha: isInMonth ? 0.2 : 0.08),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color:
                        isInMonth
                            ? colors.onSurface
                            : colors.onSurface.withValues(alpha: 0.28),
                    fontWeight:
                        hasRecord || isToday
                            ? FontWeight.w800
                            : FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (hasRecord)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tone,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            if (record?.notes?.isNotEmpty == true)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.sticky_note_2_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({
    required this.selectedDate,
    required this.record,
    required this.onAddNote,
  });

  final DateTime selectedDate;
  final AttendanceRecord? record;
  final VoidCallback? onAddNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: UiSpacing.cardPadding,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(UiRadius.card),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle del dia',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: UiSpacing.sm),
          Text(
            '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: UiSpacing.card),
          if (record == null)
            Text(
              'No hay marcacion registrada para esta fecha.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            Text(
              'Entrada ${_formatTime(record!.checkInAt)}'
              '${record!.checkOutAt != null ? ' • Salida ${_formatTime(record!.checkOutAt!)}' : ' • Salida pendiente'}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: UiSpacing.xs),
            Text(
              'Retraso: ${record!.lateArrivalMinutes} minutos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    record!.lateArrivalMinutes > 0
                        ? colors.warning
                        : colors.success,
              ),
            ),
            if (record!.notes?.isNotEmpty == true) ...[
              const SizedBox(height: UiSpacing.lg),
              Text(
                record!.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: UiSpacing.card),
            OutlinedButton.icon(
              onPressed: onAddNote,
              icon: const Icon(Icons.sticky_note_2_rounded),
              label: Text(
                record!.notes?.isNotEmpty == true
                    ? 'Editar nota'
                    : 'Agregar nota',
              ),
            ),
          ],
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
  const _CalendarEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.all(UiSpacing.cardXl),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_rounded, color: colors.primary),
          const SizedBox(height: UiSpacing.md),
          Text(
            'Aun no hay historial disponible',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: UiSpacing.xs),
          Text(
            'Registra tu primera entrada para empezar a llenar el calendario.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
