import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';

class LocalStorageService {
  static const String userBoxName = 'userBox';
  static const String medicationBoxName = 'medicationBox';
  static const String doseLogBoxName = 'doseLogBox';

  Future<void> init() async {
    // Register Adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(MedicationModelAdapter());
    Hive.registerAdapter(DoseLogModelAdapter());

    // Open Boxes
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<MedicationModel>(medicationBoxName);
    await Hive.openBox<DoseLogModel>(doseLogBoxName);
  }

  // --- User Operations ---
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.put('currentUser', user);
  }

  UserModel? getUser() {
    final box = Hive.box<UserModel>(userBoxName);
    return box.get('currentUser');
  }

  Future<void> clearUser() async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.clear();
  }

  // --- Medication Operations ---
  Future<void> saveMedication(MedicationModel med) async {
    final box = Hive.box<MedicationModel>(medicationBoxName);
    await box.put(med.medId, med);
  }

  List<MedicationModel> getMedications() {
    final box = Hive.box<MedicationModel>(medicationBoxName);
    return box.values.toList();
  }

  Future<void> deleteMedication(String medId) async {
    final box = Hive.box<MedicationModel>(medicationBoxName);
    await box.delete(medId);
  }

  // --- DoseLog Operations ---
  Future<void> saveDoseLog(DoseLogModel log) async {
    final box = Hive.box<DoseLogModel>(doseLogBoxName);
    await box.put(log.logId, log);
  }

  List<DoseLogModel> getDoseLogs({DateTime? date, String? medId}) {
    final box = Hive.box<DoseLogModel>(doseLogBoxName);
    var logs = box.values.toList();

    if (date != null) {
      logs = logs.where((log) {
        return log.scheduledTime.year == date.year &&
            log.scheduledTime.month == date.month &&
            log.scheduledTime.day == date.day;
      }).toList();
    }

    if (medId != null) {
      logs = logs.where((log) => log.medId == medId).toList();
    }

    return logs;
  }

  Future<void> deleteDoseLog(String logId) async {
    final box = Hive.box<DoseLogModel>(doseLogBoxName);
    await box.delete(logId);
  }

  Future<void> clearAll() async {
    await Hive.box<UserModel>(userBoxName).clear();
    await Hive.box<MedicationModel>(medicationBoxName).clear();
    await Hive.box<DoseLogModel>(doseLogBoxName).clear();
  }
}
