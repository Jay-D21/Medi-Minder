import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_shell.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/today_screen.dart';
import '../screens/medications_list_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/add_medication_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home/today',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: '/home/meds',
          builder: (context, state) => const MedicationsListScreen(),
        ),
        GoRoute(
          path: '/home/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/home/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-med',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddMedicationScreen(),
    ),
  ],
  redirect: (context, state) {
    // Basic redirect logic (expand as needed)
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // bool isAuthenticated = authProvider.isAuthenticated || authProvider.isGuest;

    // if (!isAuthenticated && !state.uri.toString().startsWith('/splash') && !state.uri.toString().startsWith('/login') && !state.uri.toString().startsWith('/signup') && !state.uri.toString().startsWith('/onboarding')) {
    //    return '/login';
    // }
    return null;
  },
);
