import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_storage_service.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';

class SyncService {
  final LocalStorageService _localStorage;
  final FirestoreService _firestore;

  SyncService(this._localStorage, this._firestore);

  // Sync data to cloud
  Future<void> syncToCloud() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return; // No internet
    }

    UserModel? currentUser = _localStorage.getUser();
    if (currentUser == null) return; // Only sync if logged in

    try {
      // 1. Sync User Profile
      await _firestore.updateUserProfile(currentUser);

      // 2. Sync Medications
      List<MedicationModel> meds = _localStorage.getMedications();
      // Filter for meds belonging to current user
      meds = meds.where((m) => m.userId == currentUser.userId).toList();
      await _firestore.syncMedications(meds);

      // 3. Sync Logs
      // For efficiency, mostly likely we only want to sync recent logs or unsynced logs
      // but for MVP we'll blindly batch sync all logs for robustness
      List<DoseLogModel> logs = _localStorage.getDoseLogs();
      // In a real app, we'd filter by userId and dirty/synced flags
      await _firestore.syncDoseLogs(logs);
    } catch (e) {
      print('Sync failed: $e');
      // Handle error (e.g., retry later)
    }
  }

  // Initial Sync from Cloud (e.g., on login)
  Future<void> syncFromCloud(String userId) async {
    // Implement fetching data from Firestore and populating Hive
    // This is complex and depends on "last modified" timestamps
    // For MVP, we might prioritize "Local Write -> Cloud Backup" flow
    // and assume single-device usage primarily

    // Placeholder for download logic
  }
}
