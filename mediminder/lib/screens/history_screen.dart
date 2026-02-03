import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import '../providers/medication_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdProvider>(context, listen: false).showInterstitialIfReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No history yet',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking medications to see your history',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Adherence',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          '${provider.medications.length} Medications',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...provider.medications.map((med) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: med.colorObj.withOpacity(0.2),
                        child: Icon(Icons.medication, color: med.colorObj),
                      ),
                      title: Text(med.name),
                      subtitle: Text('${med.dosage} ${med.dosageUnit}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${med.currentSupply}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('left', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
