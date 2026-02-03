import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication),
            label: 'Meds',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/today')) return 0;
    if (location.startsWith('/home/meds')) return 1;
    if (location.startsWith('/home/history')) return 2;
    if (location.startsWith('/home/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/today');
        break;
      case 1:
        context.go('/home/meds');
        break;
      case 2:
        context.go('/home/history');
        break;
      case 3:
        context.go('/home/profile');
        break;
    }
  }
}
