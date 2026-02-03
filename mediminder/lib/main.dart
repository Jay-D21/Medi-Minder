import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'themes/app_theme.dart';
import 'utils/router.dart';
import 'providers/auth_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/dose_provider.dart';
import 'providers/ad_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProxyProvider<MedicationProvider, DoseProvider>(
          create: (_) => DoseProvider(),
          update: (_, medProvider, doseProvider) {
            doseProvider ??= DoseProvider();
            doseProvider.loadTodayDoses(medProvider.medications);
            return doseProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: MaterialApp.router(
        title: 'MediMinder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
