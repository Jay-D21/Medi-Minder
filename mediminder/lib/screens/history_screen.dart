import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ad_provider.dart';
import '../providers/medication_provider.dart';
import '../services/local_storage_service.dart';
import '../models/dose_log_model.dart';
import '../themes/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalStorageService _storage = LocalStorageService();
  int _takenCount = 0;
  int _skippedCount = 0;
  int _streak = 0;
  List<DoseLogModel> _recentLogs = [];
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
      _loadBannerAd();
    });
  }

  void _loadBannerAd() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    if (!adProvider.isPremium) {
      _bannerAd = adProvider.createBanner(() {
        if (mounted) setState(() => _isAdLoaded = true);
      });
      _bannerAd?.load();
    }
  }

  void _loadStats() {
    final logs = _storage.getDoseLogs();
    final taken = logs.where((l) => l.status == 'taken').toList();
    final skipped = logs.where((l) => l.status == 'skipped').toList();

    // Calculate streak
    int streak = 0;
    if (taken.isNotEmpty) {
      taken.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      DateTime? lastDate;
      for (var log in taken) {
        final logDate = DateTime(log.scheduledTime.year,
            log.scheduledTime.month, log.scheduledTime.day);
        if (lastDate == null) {
          streak = 1;
          lastDate = logDate;
        } else if (lastDate.difference(logDate).inDays == 1) {
          streak++;
          lastDate = logDate;
        } else {
          break;
        }
      }
    }

    setState(() {
      _takenCount = taken.length;
      _skippedCount = skipped.length;
      _streak = streak;
      _recentLogs = logs.take(10).toList();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final total = _takenCount + _skippedCount;
    final adherence = total > 0 ? ((_takenCount / total) * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Analytics',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MedicationProvider>(
              builder: (context, medProvider, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Main Stats Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                  value: '$adherence%',
                                  label: 'Adherence',
                                  icon: Icons.analytics),
                              _StatItem(
                                  value: '$_streak',
                                  label: 'Day Streak',
                                  icon: Icons.local_fire_department),
                              _StatItem(
                                  value: '${medProvider.medications.length}',
                                  label: 'Active Meds',
                                  icon: Icons.medication),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dose Stats
                    Row(
                      children: [
                        Expanded(
                            child: _InfoCard(
                                title: 'Taken',
                                value: '$_takenCount',
                                color: Colors.green,
                                icon: Icons.check_circle,
                                isDark: isDark)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _InfoCard(
                                title: 'Skipped',
                                value: '$_skippedCount',
                                color: Colors.orange,
                                icon: Icons.cancel,
                                isDark: isDark)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Activity
                    Text('Recent Activity',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    if (_recentLogs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.history,
                                size: 48,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('No activity yet',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600)),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_recentLogs.length, (i) {
                        final log = _recentLogs[i];
                        final med = medProvider.medications
                            .where((m) => m.medId == log.medId)
                            .firstOrNull;
                        return _ActivityItem(
                            log: log,
                            medName: med?.name ?? 'Unknown',
                            isDark: isDark);
                      }),
                  ],
                );
              },
            ),
          ),

          // Banner Ad
          if (_isAdLoaded && _bannerAd != null)
            SafeArea(
              child: Container(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                color: theme.scaffoldBackgroundColor,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _InfoCard(
      {required this.title,
      required this.value,
      required this.color,
      required this.icon,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(title,
                  style: TextStyle(
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final DoseLogModel log;
  final String medName;
  final bool isDark;
  const _ActivityItem(
      {required this.log, required this.medName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isTaken = log.status == 'taken';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTaken
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.2),
          child: Icon(isTaken ? Icons.check : Icons.close,
              color: isTaken ? Colors.green : Colors.orange, size: 20),
        ),
        title:
            Text(medName, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          DateFormat('MMM d, h:mm a').format(log.scheduledTime),
          style: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isTaken ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(isTaken ? 'Taken' : 'Skipped',
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ),
    );
  }
}
