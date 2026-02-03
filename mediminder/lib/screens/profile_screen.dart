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
      appBar: AppBar(
          title: const Text('Profile',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1a237e), Color(0xFF3949ab)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1a237e).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Icon(
                      authProvider.isAuthenticated
                          ? Icons.person
                          : Icons.person_outline,
                      size: 40,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.isAuthenticated
                      ? (authProvider.userEmail ?? 'User')
                      : 'Guest User',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    authProvider.isAuthenticated ? 'Signed In' : 'Guest Mode',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                if (!authProvider.isAuthenticated) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showSignInDialog(context),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1a237e),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign In Section (for guests)
          if (!authProvider.isAuthenticated) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create an Account',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700)),
                        Text(
                            'Sign in to sync your data and access more features',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text('Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _Tile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Reminder settings'),
          _Tile(
              icon: Icons.palette,
              title: 'Appearance',
              subtitle: 'Theme & display'),
          _Tile(
              icon: Icons.backup,
              title: 'Backup',
              subtitle: 'Export your data'),
          _Tile(
              icon: Icons.security,
              title: 'Privacy',
              subtitle: 'App lock & security'),

          const SizedBox(height: 24),
          Text('About',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _Tile(icon: Icons.info, title: 'App Info', subtitle: 'Version 1.0.0'),
          _Tile(icon: Icons.help, title: 'Help & FAQ', subtitle: 'Get support'),
          _Tile(
              icon: Icons.star, title: 'Rate App', subtitle: 'Leave a review'),

          const SizedBox(height: 32),

          if (authProvider.isAuthenticated)
            ElevatedButton.icon(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Sign In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Sign in to save your data',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final success =
                    await authProvider.signInWithEmail(email, password);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Signed in successfully!'),
                          backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(authProvider.error ?? 'Sign in failed')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final success =
                    await authProvider.signUpWithEmail(email, password);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Account created successfully!'),
                          backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(authProvider.error ?? 'Sign up failed')),
                    );
                  }
                }
              },
              child: const Text("Don't have an account? Create one"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Tile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1a237e).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1a237e)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {},
      ),
    );
  }
}
