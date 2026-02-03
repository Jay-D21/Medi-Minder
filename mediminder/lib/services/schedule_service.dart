import '../models/medication_model.dart';
import '../models/dose_log_model.dart';

class ScheduleService {
  List<DoseLogModel> generateDailySchedule(
      List<MedicationModel> medications, DateTime date) {
    List<DoseLogModel> scheduledDoses = [];

    for (var med in medications) {
      if (!med.isActive) continue;

      // Check if med is scheduled for this date based on FrequencyType
      bool isScheduledToday = _isScheduledForDate(med, date);

      if (isScheduledToday) {
        for (String timeStr in med.scheduleTimes) {
          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          final scheduledTime =
              DateTime(date.year, date.month, date.day, hour, minute);

          scheduledDoses.add(DoseLogModel(
            logId:
                '${med.medId}_${scheduledTime.millisecondsSinceEpoch}', // Temporary ID for UI
            medId: med.medId,
            scheduledTime: scheduledTime,
            status: 'scheduled',
          ));
        }
      }
    }

    return scheduledDoses;
  }

  bool _isScheduledForDate(MedicationModel med, DateTime date) {
    if (med.frequencyType == 'Daily') {
      return true;
    } else if (med.frequencyType == 'Every X Days') {
      // Logic: (date - createdAt) % interval == 0
      final diff = date.difference(med.createdAt).inDays;
      return diff % (med.intervalDays ?? 1) == 0;
    } else if (med.frequencyType == 'Specific Days') {
      // Logic: Check if date.weekday is in specificDays list
      // Note: DateTime weekday 1=Mon, 7=Sun
      // Our specificDays list might store strings or ints. Assuming List<int> 1-7 for MVP.
      // If strings, need mapping.

      // For MVP simplicity, let's assume specificDays contains ints 1-7
      if (med.specificDays != null &&
          med.specificDays!.contains(date.weekday)) {
        return true;
      }
      return false;
    }

    return false;
  }
}
