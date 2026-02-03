import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.isGuest
                      ? 'Guest User'
                      : (authProvider.userEmail ?? 'User'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.isGuest ? 'Guest Mode' : 'Local Account',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Settings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _Tile(icon: Icons.notifications, title: 'Notifications'),
          _Tile(icon: Icons.palette, title: 'Appearance'),
          _Tile(icon: Icons.backup, title: 'Backup'),
          _Tile(icon: Icons.security, title: 'Privacy'),
          const SizedBox(height: 24),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _Tile(icon: Icons.info, title: 'App Info'),
          _Tile(icon: Icons.help, title: 'Help'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Tile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1a237e)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
