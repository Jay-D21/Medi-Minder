import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Provider.of<AuthProvider>(context, listen: false).signOut();
            if (context.mounted) context.go('/login');
          },
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
