import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MedicationsListScreen extends StatelessWidget {
  const MedicationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Medications')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-med'),
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text('Medication Inventory')),
    );
  }
}
