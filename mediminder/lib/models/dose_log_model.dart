import 'package:hive/hive.dart';

part 'dose_log_model.g.dart';

@HiveType(typeId: 2)
class DoseLogModel extends HiveObject {
  @HiveField(0)
  final String logId;

  @HiveField(1)
  final String medId;

  @HiveField(2)
  final DateTime scheduledTime;

  @HiveField(3)
  final DateTime? actionTime;

  @HiveField(4)
  final String status; // 'scheduled', 'taken', 'skipped', 'snoozed'

  @HiveField(5)
  final String? notes;

  DoseLogModel({
    required this.logId,
    required this.medId,
    required this.scheduledTime,
    this.actionTime,
    required this.status,
    this.notes,
  });

  DoseLogModel copyWith({
    String? logId,
    String? medId,
    DateTime? scheduledTime,
    DateTime? actionTime,
    String? status,
    String? notes,
  }) {
    return DoseLogModel(
      logId: logId ?? this.logId,
      medId: medId ?? this.medId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actionTime: actionTime ?? this.actionTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
