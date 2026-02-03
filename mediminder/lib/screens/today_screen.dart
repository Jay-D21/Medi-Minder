import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-med'),
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text('Today\'s Schedule')),
    );
  }
}
