import 'package:flutter/material.dart';
import '../models/dose_log_model.dart';
import '../services/local_storage_service.dart';
import '../services/schedule_service.dart';
import '../models/medication_model.dart';

class DoseProvider with ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  final ScheduleService _scheduleService = ScheduleService();

  List<DoseLogModel> _todayDoses = [];
  bool _isLoading = false;

  List<DoseLogModel> get todayDoses => _todayDoses;
  bool get isLoading => _isLoading;

  Future<void> loadTodayDoses(List<MedicationModel> medications) async {
    _isLoading = true;
    notifyListeners();

    final today = DateTime.now();

    // 1. Get existing logs for today
    List<DoseLogModel> existingLogs =
        _localStorageService.getDoseLogs(date: today);

    // 2. Generate expected schedule if not fully present
    // For MVP efficiency, we might just regenerate transiently or check if we need to create "scheduled" logs
    // Ideally, we persist "scheduled" logs at the beginning of the day or when adding meds

    // Simplification: Generate 'Transient' logs for display, merge with 'Persisted' action logs
    List<DoseLogModel> scheduledDoses =
        _scheduleService.generateDailySchedule(medications, today);

    // Merge: If a log exists for a scheduled dose (matched by medId and time), use the log (status: taken/skipped).
    // Otherwise use the scheduled dose (status: scheduled).

    List<DoseLogModel> mergedDoses = [];

    for (var scheduled in scheduledDoses) {
      // Find matching existing log
      // Matching criteria: Same MedId and close scheduledTime (e.g. within 1 minute to account for precision loss)

      try {
        var existing = existingLogs.firstWhere((log) =>
            log.medId == scheduled.medId &&
            log.scheduledTime.year == scheduled.scheduledTime.year &&
            log.scheduledTime.month == scheduled.scheduledTime.month &&
            log.scheduledTime.day == scheduled.scheduledTime.day &&
            log.scheduledTime.hour == scheduled.scheduledTime.hour &&
            log.scheduledTime.minute == scheduled.scheduledTime.minute);
        mergedDoses.add(existing);
      } catch (e) {
        // No existing action log found, so it is still "scheduled"
        mergedDoses.add(scheduled);
      }
    }

    _todayDoses = mergedDoses;
    _todayDoses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsTaken(String medId, DateTime scheduledTime) async {
    // Create or update log
    final newLog = DoseLogModel(
      logId: '${medId}_${scheduledTime.millisecondsSinceEpoch}',
      medId: medId,
      scheduledTime: scheduledTime,
      actionTime: DateTime.now(),
      status: 'taken',
    );

    await _localStorageService.saveDoseLog(newLog);

    // Update local state
    final index = _todayDoses.indexWhere((d) =>
        d.medId == medId && d.scheduledTime.isAtSameMomentAs(scheduledTime));

    if (index != -1) {
      _todayDoses[index] = newLog;
    } else {
      _todayDoses.add(newLog);
    }

    notifyListeners();
  }

  Future<void> markAsSkipped(String medId, DateTime scheduledTime) async {
    final newLog = DoseLogModel(
      logId: '${medId}_${scheduledTime.millisecondsSinceEpoch}',
      medId: medId,
      scheduledTime: scheduledTime,
      actionTime: DateTime.now(),
      status: 'skipped',
    );

    await _localStorageService.saveDoseLog(newLog);
    // Update local state is similar to taken...
    notifyListeners();
  }
}
