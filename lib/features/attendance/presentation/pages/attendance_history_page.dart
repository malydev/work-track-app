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
  DateTime _selectedDate = DateTime.now();
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
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
              final recordsByDate = {
                for (final record in records) record.dateKey: record,
              };
              return Column(
                children: [
                  _SummaryPanel(records: records),
                  const SizedBox(height: UiSpacing.cardLg),
                  _MonthCalendar(
                    visibleMonth: _visibleMonth,
                    selectedDate: _selectedDate,
                    recordsByDate: recordsByDate,
                    onPreviousMonth:
                        () => setState(
                          () =>
                              _visibleMonth = DateTime(
                                _visibleMonth.year,
                                _visibleMonth.month - 1,
                              ),
                        ),
                    onNextMonth:
                        () => setState(
                          () =>
                              _visibleMonth = DateTime(
                                _visibleMonth.year,
                                _visibleMonth.month + 1,
                              ),
                        ),
                    onSelectDate:
                        (date) => setState(() {
                          _selectedDate = date;
                          _visibleMonth = DateTime(date.year, date.month);
                        }),
                  ),
                  const SizedBox(height: UiSpacing.cardLg),
                  _SelectedDayPanel(
                    selectedDate: _selectedDate,
                    record: _recordForSelectedDate(recordsByDate),
                    onAddNote:
                        _recordForSelectedDate(recordsByDate) == null
                            ? null
                            : () => _showNoteSheet(
                              _recordForSelectedDate(recordsByDate)!,
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

  AttendanceRecord? _recordForSelectedDate(
    Map<String, AttendanceRecord> recordsByDate,
  ) {
    return recordsByDate[_dateKey(_selectedDate)];
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
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.visibleMonth,
    required this.selectedDate,
    required this.recordsByDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Map<String, AttendanceRecord> recordsByDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final monthDays = _buildCalendarDays(visibleMonth);
    final monthLabel = _monthLabel(visibleMonth);

    return Container(
      padding: UiSpacing.cardPadding,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(UiRadius.sheet),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.md),
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Center(
                  child: Text(
                    const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][index],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: UiSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final date = monthDays[index];
              final isInMonth = date.month == visibleMonth.month;
              final isSelected = _isSameDate(date, selectedDate);
              final dateKey = _dateKey(date);
              final record = recordsByDate[dateKey];

              return _CalendarCell(
                date: date,
                isToday: _isSameDate(date, DateTime.now()),
                isInMonth: isInMonth,
                isSelected: isSelected,
                record: record,
                onTap: () => onSelectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DateTime> _buildCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekdayOffset = firstDayOfMonth.weekday - DateTime.monday;
    final calendarStart = firstDayOfMonth.subtract(
      Duration(days: firstWeekdayOffset),
    );
    final lastWeekdayPadding = DateTime.sunday - lastDayOfMonth.weekday;
    final calendarEnd = lastDayOfMonth.add(Duration(days: lastWeekdayPadding));
    final totalDays = calendarEnd.difference(calendarStart).inDays + 1;

    return List.generate(
      totalDays,
      (index) => calendarStart.add(Duration(days: index)),
    );
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthLabel(DateTime value) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${months[value.month - 1]} ${value.year}';
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
    required this.isSelected,
    required this.record,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isInMonth;
  final bool isSelected;
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
                isSelected
                    ? colors.primary
                    : hasRecord
                    ? tone.withValues(alpha: 0.5)
                    : colors.border.withValues(alpha: isInMonth ? 0.2 : 0.08),
            width: isSelected ? 1.4 : 1,
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
