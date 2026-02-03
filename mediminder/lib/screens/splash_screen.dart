import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Simulate splash delay (e.g. for branding or loading initial data)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated || authProvider.isGuest) {
      context.go('/home/today');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with actual Logo asset
            Icon(
              Icons.medication,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'MediMinder',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
