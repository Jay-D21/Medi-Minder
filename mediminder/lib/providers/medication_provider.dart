import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

class MedicationProvider with ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  final NotificationService _notificationService = NotificationService();

  List<MedicationModel> _medications = [];
  bool _isLoading = false;
  String? _error;

  List<MedicationModel> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MedicationProvider() {
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _medications = _localStorageService.getMedications();
    } catch (e) {
      _error = "Failed to load medications";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(MedicationModel med) async {
    try {
      await _localStorageService.saveMedication(med);
      _medications.add(med);

      // Schedule reminders
      // This is simplified; real logic needs to calculate next occurrence based on frequencyType
      // For MVP demo, scheduling for the next valid times today/tomorrow
      for (String timeStr in med.scheduleTimes) {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final now = DateTime.now();
        DateTime scheduledTime =
            DateTime(now.year, now.month, now.day, hour, minute);

        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        await _notificationService.scheduleDoseReminder(med, scheduledTime);
      }

      notifyListeners();
    } catch (e) {
      _error = "Failed to add medication";
      notifyListeners();
    }
  }

  Future<void> updateMedication(MedicationModel med) async {
    try {
      await _localStorageService.saveMedication(med);
      final index = _medications.indexWhere((m) => m.medId == med.medId);
      if (index != -1) {
        _medications[index] = med;
        // Re-schedule logic would go here (cancel old, schedule new)
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update medication";
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String medId) async {
    try {
      await _localStorageService.deleteMedication(medId);
      _medications.removeWhere((m) => m.medId == medId);
      // Cancel notifications logic would go here
      notifyListeners();
    } catch (e) {
      _error = "Failed to delete medication";
      notifyListeners();
    }
  }

  void decrementSupply(String medId) {
    final index = _medications.indexWhere((m) => m.medId == medId);
    if (index != -1) {
      MedicationModel med = _medications[index];
      med.currentSupply = med.currentSupply - 1;
      _localStorageService.saveMedication(med);

      // Check for low supply
      if (med.currentSupply <= med.lowSupplyThreshold) {
        _notificationService.showLowSupplyAlert(med);
      }
      notifyListeners();
    }
  }
}
