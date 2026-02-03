import 'package:flutter_test/flutter_test.dart';
import 'package:mediminder/models/medication_model.dart';
import 'package:mediminder/services/schedule_service.dart';

void main() {
  late ScheduleService scheduleService;

  setUp(() {
    scheduleService = ScheduleService();
  });

  group('ScheduleService Tests', () {
    test('generateDailySchedule should return doses for Daily meds', () {
      final today = DateTime(2024, 1, 1);
      final med = MedicationModel(
        medId: '1',
        userId: 'u1',
        name: 'Daily Med',
        dosage: 1,
        dosageUnit: 'pill',
        frequencyType: 'Daily',
        scheduleTimes: ['09:00', '21:00'],
        iconId: 0,
        color: 0,
        isActive: true,
        createdAt: DateTime(2023, 1, 1),
      );

      final result = scheduleService.generateDailySchedule([med], today);

      expect(result.length, 2);
      expect(result[0].scheduledTime.hour, 9);
      expect(result[1].scheduledTime.hour, 21);
      expect(result[0].status, 'scheduled');
    });

    test('generateDailySchedule should respect Every X Days', () {
      final start = DateTime(2024, 1, 1); // Monday
      final med = MedicationModel(
        medId: '2',
        userId: 'u1',
        name: 'Every 2 Days',
        dosage: 1,
        dosageUnit: 'pill',
        frequencyType: 'Every X Days',
        intervalDays: 2,
        scheduleTimes: ['10:00'],
        iconId: 0,
        color: 0,
        isActive: true,
        createdAt: start,
      );

      // Day 0 (Start): Should include
      var result = scheduleService.generateDailySchedule([med], start);
      expect(result.length, 1);

      // Day 1 (Start + 1): Should exclude
      result = scheduleService
          .generateDailySchedule([med], start.add(const Duration(days: 1)));
      expect(result.length, 0);

      // Day 2 (Start + 2): Should include
      result = scheduleService
          .generateDailySchedule([med], start.add(const Duration(days: 2)));
      expect(result.length, 1);
    });
  });
}
