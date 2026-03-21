import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/features/attendance/constants/attendance_messages.dart';
import 'package:work_track/features/attendance/domain/entities/attendance_record.dart';
import 'package:work_track/shared/providers/app_providers.dart';

final attendanceControllerProvider =
    NotifierProvider<AttendanceController, AttendanceControllerState>(
      AttendanceController.new,
    );

class AttendanceController extends Notifier<AttendanceControllerState> {
  @override
  AttendanceControllerState build() {
    return const AttendanceControllerState();
  }

  Future<void> registerCheckIn({
    String? userId,
    String? notes,
    DateTime? now,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final effectiveNow = now ?? DateTime.now();
      final effectiveUserId =
          userId ?? ref.read(currentUserProfileProvider).asData?.value?.id;
      final settings = ref.read(resolvedSettingsProvider);

      final record = await ref
          .read(registerCheckInUseCaseProvider)
          .call(
            now: effectiveNow,
            settings: settings,
            userId: effectiveUserId,
            notes: notes,
          );

      state = state.copyWith(
        isSubmitting: false,
        lastRecord: record,
        lastAction: AttendanceAction.checkIn,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AttendanceMessages.checkInError,
      );
    }
  }

  Future<void> registerCheckOut({String? userId, DateTime? now}) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final effectiveNow = now ?? DateTime.now();
      final effectiveUserId =
          userId ?? ref.read(currentUserProfileProvider).asData?.value?.id;

      final record = await ref
          .read(registerCheckOutUseCaseProvider)
          .call(now: effectiveNow, userId: effectiveUserId);

      if (record == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: AttendanceMessages.missingCheckIn,
        );
        return;
      }

      state = state.copyWith(
        isSubmitting: false,
        lastRecord: record,
        lastAction: AttendanceAction.checkOut,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AttendanceMessages.checkOutError,
      );
    }
  }

  Future<void> saveNote({
    required AttendanceRecord record,
    required String? note,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final normalizedNote = note?.trim();
      final updated = record.copyWith(
        notes:
            normalizedNote == null || normalizedNote.isEmpty
                ? null
                : normalizedNote,
        updatedAt: DateTime.now(),
        clearNotes: normalizedNote == null || normalizedNote.isEmpty,
      );

      await ref.read(saveAttendanceRecordUseCaseProvider).call(updated);

      state = state.copyWith(isSubmitting: false, lastRecord: updated);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AttendanceMessages.saveNoteError,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

enum AttendanceAction { checkIn, checkOut }

class AttendanceControllerState {
  const AttendanceControllerState({
    this.isSubmitting = false,
    this.errorMessage,
    this.lastRecord,
    this.lastAction,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final AttendanceRecord? lastRecord;
  final AttendanceAction? lastAction;

  AttendanceControllerState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    AttendanceRecord? lastRecord,
    AttendanceAction? lastAction,
    bool clearError = false,
    bool clearLastRecord = false,
    bool clearLastAction = false,
  }) {
    return AttendanceControllerState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastRecord: clearLastRecord ? null : lastRecord ?? this.lastRecord,
      lastAction: clearLastAction ? null : lastAction ?? this.lastAction,
    );
  }
}
