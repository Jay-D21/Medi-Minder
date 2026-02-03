import 'package:flutter/foundation.dart';
import '../models/medication_model.dart';

/// Simplified notification service for offline mode
/// Full notifications will be re-enabled when Android build issues are resolved
class NotificationService {
  static const String channelId = 'mediminder_reminders';
  static const String channelName = 'Medication Reminders';

  Future<void> init() async {
    // Notifications temporarily disabled due to Android build compatibility
    debugPrint('NotificationService initialized (stub mode)');
  }

  Future<void> scheduleDoseReminder(
      MedicationModel med, DateTime scheduledTime) async {
    // Stub - notifications temporarily disabled
    debugPrint('Would schedule reminder for ${med.name} at $scheduledTime');
  }

  Future<void> cancelReminder(int notificationId) async {
    // Stub
  }

  Future<void> cancelAll() async {
    // Stub
  }

  Future<void> showLowSupplyAlert(MedicationModel med) async {
    // Stub - notifications temporarily disabled
    debugPrint(
        'Low supply alert for ${med.name}: ${med.currentSupply} remaining');
  }
}
