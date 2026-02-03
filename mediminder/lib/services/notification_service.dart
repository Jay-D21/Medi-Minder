import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medication_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'mediminder_reminders';
  static const String channelName = 'Medication Reminders';
  static const String channelDescription =
      'High importance notifications for medication reminders';

  Future<void> init() async {
    tz.initializeTimeZones();

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Create Notification Channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Schedule a specific dose
  Future<void> scheduleDoseReminder(
      MedicationModel med, DateTime scheduledTime) async {
    // Unique ID generation strategy: valid logic required to avoid collisions
    // For MVP, we might use hash of medId + time, but int range is limited.
    // A robust app would maintain a separate DB for notification IDs.
    // Here using a simple hash for demonstration.
    int notificationId =
        '${med.medId}_${scheduledTime.millisecondsSinceEpoch}'.hashCode;

    // Ensure ID fits in 32-bit int
    if (notificationId > 2147483647)
      notificationId = notificationId % 2147483647;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Time to take ${med.name}',
      'Dosage: ${med.dosage} ${med.dosageUnit}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Medication Reminder',
          actions: [
            AndroidNotificationAction('TAKE', 'Take Now'),
            AndroidNotificationAction('SNOOZE', 'Snooze 15m'),
            AndroidNotificationAction('SKIP', 'Skip'),
          ],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'medication_category',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${med.medId}|${scheduledTime.toIso8601String()}',
    );
  }

  Future<void> cancelReminder(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Handle Foreground/Background interaction
  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      // Navigate to Dose Alert Screen or handle action
      // Use a GlobalKey<NavigatorState> or Router to handle navigation if needed
      print('Notification payload: ${response.payload}');
      print('Action ID: ${response.actionId}');
    }
  }

  // Background handler must be static
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background actions (e.g., mark as taken without opening app)
    print('Background Action: ${response.actionId}');
    // Would typically interact with Hive/Isolate here
  }
}
