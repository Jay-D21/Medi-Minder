import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Assuming google-services.json is set up)
  // await Firebase.initializeApp(); // Uncomment when ready to test on device with valid config

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Local Storage Service (Registers adapters and opens boxes)
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MediMinderApp());
}

class MediMinderApp extends StatelessWidget {
  const MediMinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D9CDB)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const Scaffold(
        body: Center(
          child: Text('MediMinder Initialized'),
        ),
      ),
    );
  }
}
