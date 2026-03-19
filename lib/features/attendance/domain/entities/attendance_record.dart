class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.dateKey,
    required this.checkInAt,
    this.checkOutAt,
    this.userId,
    this.notes,
    this.lateArrivalMinutes = 0,
    this.updatedAt,
  });

  final String id;
  final String dateKey;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final String? userId;
  final String? notes;
  final int lateArrivalMinutes;
  final DateTime? updatedAt;

  AttendanceRecord copyWith({
    String? id,
    String? dateKey,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    String? userId,
    String? notes,
    int? lateArrivalMinutes,
    DateTime? updatedAt,
    bool clearCheckOutAt = false,
    bool clearNotes = false,
    bool clearUpdatedAt = false,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: clearCheckOutAt ? null : checkOutAt ?? this.checkOutAt,
      userId: userId ?? this.userId,
      notes: clearNotes ? null : notes ?? this.notes,
      lateArrivalMinutes: lateArrivalMinutes ?? this.lateArrivalMinutes,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }
}
