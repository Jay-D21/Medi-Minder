import 'package:flutter_test/flutter_test.dart';
import 'package:mediminder/models/medication_model.dart';

void main() {
  group('MedicationModel Tests', () {
    test('should create valid MedicationModel', () {
      final med = MedicationModel(
        medId: '123',
        userId: 'user1',
        name: 'Aspirin',
        dosage: 100,
        dosageUnit: 'mg',
        frequencyType: 'Daily',
        scheduleTimes: ['08:00'],
        iconId: 1,
        color: 0xFFFFFFFF,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(med.name, 'Aspirin');
      expect(med.scheduleTimes.length, 1);
    });

    // Note: Testing Hive serialization specifically requires initializing Hive in tests
    // or mocking. For simple model tests, we verify the object properties structure.
  });
}
