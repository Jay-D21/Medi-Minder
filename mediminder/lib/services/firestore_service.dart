import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _medications => _db.collection('medications');
  CollectionReference get _logs => _db.collection('logs');

  // --- User Operations ---

  Future<void> createUserProfile(UserModel user) async {
    await _users.doc(user.userId).set({
      'email': user.email,
      'displayName': user.displayName,
      'timezone': user.timezone,
      'soundPreferences': user.soundPreferences,
      'isPremium': user.isPremium,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'lastSynced': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _users.doc(user.userId).update({
      'displayName': user.displayName,
      'timezone': user.timezone,
      'soundPreferences': user.soundPreferences,
      'isPremium': user.isPremium,
      'lastSynced': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _users.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // --- Medication Operations ---

  // Batch sync medications
  Future<void> syncMedications(List<MedicationModel> meds) async {
    if (meds.isEmpty) return;

    WriteBatch batch = _db.batch();

    for (var med in meds) {
      DocumentReference docRef = _medications.doc(med.medId);
      batch.set(
          docRef,
          {
            'userId': med.userId,
            'name': med.name,
            'dosage': med.dosage,
            'dosageUnit': med.dosageUnit,
            'frequencyType': med.frequencyType,
            'scheduleTimes': med.scheduleTimes,
            'iconId': med.iconId,
            'color': med.color,
            'currentSupply': med.currentSupply,
            'lowSupplyThreshold': med.lowSupplyThreshold,
            'isActive': med.isActive,
            'createdAt': Timestamp.fromDate(med.createdAt),
            'specificDays': med.specificDays,
            'intervalDays': med.intervalDays,
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> deleteMedication(String medId) async {
    await _medications.doc(medId).delete();
  }

  // --- Log Operations ---

  Future<void> syncDoseLogs(List<DoseLogModel> logs) async {
    if (logs.isEmpty) return;

    WriteBatch batch = _db.batch();

    for (var log in logs) {
      DocumentReference docRef = _logs.doc(log.logId);
      batch.set(
          docRef,
          {
            'medId': log.medId,
            'scheduledTime': Timestamp.fromDate(log.scheduledTime),
            'actionTime': log.actionTime != null
                ? Timestamp.fromDate(log.actionTime!)
                : null,
            'status': log.status,
            'notes': log.notes,
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Fetch logs for a specific user within a date range (for reports/history on new device)
  Future<QuerySnapshot> getLogsForUser(
      String userId, DateTime start, DateTime end) async {
    // Note: This query requires a complex index in Firestore
    // For MVP, we might just fetch by userId and filter locally if dataset is small
    // Or assume we sync everything down
    return await _logs
        .where('userId', isEqualTo: userId)
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
  }
}
