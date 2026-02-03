import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ad_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/dose_provider.dart';
import '../services/local_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalStorageService _storage = LocalStorageService();
  int _takenCount = 0;
  int _skippedCount = 0;
  int _totalDoses = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdProvider>(context, listen: false).showInterstitialIfReady();
      _loadStats();
    });
  }

  void _loadStats() {
    final logs = _storage.getDoseLogs();
    setState(() {
      _takenCount = logs.where((l) => l.status == 'taken').length;
      _skippedCount = logs.where((l) => l.status == 'skipped').length;
      _totalDoses = logs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & History',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer2<MedicationProvider, DoseProvider>(
        builder: (context, medProvider, doseProvider, child) {
          final adherenceRate =
              _totalDoses > 0 ? ((_takenCount / _totalDoses) * 100).round() : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Analytics Cards
              Text('Adherence Analytics',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Main Stats Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Overall Adherence',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: _totalDoses > 0
                                        ? _takenCount / _totalDoses
                                        : 0,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text('$adherenceRate%',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold)),
                                    const Text('rate',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatRow(
                                icon: Icons.check_circle,
                                label: 'Taken',
                                value: _takenCount.toString(),
                                color: Colors.green),
                            const SizedBox(height: 8),
                            _StatRow(
                                icon: Icons.cancel,
                                label: 'Skipped',
                                value: _skippedCount.toString(),
                                color: Colors.orange),
                            const SizedBox(height: 8),
                            _StatRow(
                                icon: Icons.medication,
                                label: 'Active Meds',
                                value:
                                    medProvider.medications.length.toString(),
                                color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                      child: _QuickStatCard(
                          title: 'Today',
                          value:
                              '${doseProvider.todayDoses.where((d) => d.status == 'taken').length}/${doseProvider.todayDoses.length}',
                          icon: Icons.today,
                          color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _QuickStatCard(
                          title: 'Streak',
                          value: '${_calculateStreak()} days',
                          icon: Icons.local_fire_department,
                          color: Colors.orange)),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Text('Recent Activity',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_totalDoses == 0)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Icon(Icons.history,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No history yet',
                          style: TextStyle(color: Colors.grey.shade600)),
                      Text('Start taking medications to build your history',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                )
              else
                ..._buildRecentLogs(),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  int _calculateStreak() {
    final logs = _storage.getDoseLogs();
    if (logs.isEmpty) return 0;

    // Simple streak: count consecutive days with at least one taken dose
    final takenLogs = logs.where((l) => l.status == 'taken').toList();
    if (takenLogs.isEmpty) return 0;

    takenLogs.sort((a, b) => b.actionTime!.compareTo(a.actionTime!));

    int streak = 0;
    DateTime? lastDate;

    for (final log in takenLogs) {
      final logDate = DateTime(
          log.actionTime!.year, log.actionTime!.month, log.actionTime!.day);

      if (lastDate == null) {
        streak = 1;
        lastDate = logDate;
      } else {
        final diff = lastDate.difference(logDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = logDate;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return streak;
  }

  List<Widget> _buildRecentLogs() {
    final logs = _storage.getDoseLogs();
    logs.sort((a, b) => (b.actionTime ?? b.scheduledTime)
        .compareTo(a.actionTime ?? a.scheduledTime));

    final recentLogs = logs.take(10).toList();
    final dateFormat = DateFormat('MMM d, h:mm a');

    return recentLogs.map((log) {
      final meds =
          Provider.of<MedicationProvider>(context, listen: false).medications;
      final med = meds.firstWhere((m) => m.medId == log.medId,
          orElse: () =>
              meds.isNotEmpty ? meds.first : throw Exception('No meds'));

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: log.status == 'taken'
                ? Colors.green.shade100
                : Colors.grey.shade200,
            child: Icon(
              log.status == 'taken' ? Icons.check : Icons.close,
              color: log.status == 'taken' ? Colors.green : Colors.grey,
            ),
          ),
          title: Text(med.name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle:
              Text(dateFormat.format(log.actionTime ?? log.scheduledTime)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: log.status == 'taken'
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.status == 'taken' ? 'Taken ✓' : 'Skipped',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: log.status == 'taken'
                    ? Colors.green.shade700
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text('$value ',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}
