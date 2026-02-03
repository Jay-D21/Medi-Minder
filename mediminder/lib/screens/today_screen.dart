import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../providers/ad_provider.dart';
import '../providers/medication_provider.dart';
import '../models/medication_model.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() {
    final adProvider = Provider.of<AdProvider>(context);
    if (!adProvider.isPremium && _bannerAd == null) {
      _bannerAd = adProvider.createBanner(() {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      });
      _bannerAd!.load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today'),
            Text(
              dateFormat.format(now),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-med'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MedicationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todayMeds = _getTodaySchedule(provider.medications);

                if (todayMeds.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummaryCard(context, provider.medications),
                    const SizedBox(height: 20),
                    Text(
                      "Today's Schedule",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...todayMeds.map((schedule) => _ScheduleCard(
                          medication: schedule.medication,
                          time: schedule.time,
                        )),
                  ],
                );
              },
            ),
          ),
          if (_isAdLoaded && _bannerAd != null)
            Container(
              color: Colors.grey.shade100,
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2D9CDB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Color(0xFF2D9CDB),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No medications scheduled',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a medication to start tracking your doses',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-med'),
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, List<MedicationModel> medications) {
    final totalMeds = medications.length;
    final lowSupply = medications
        .where((m) => m.currentSupply <= m.lowSupplyThreshold)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D9CDB), Color(0xFF56CCF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D9CDB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Health Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  value: totalMeds.toString(),
                  label: 'Active Meds',
                  icon: Icons.medication,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white38),
              Expanded(
                child: _SummaryItem(
                  value: lowSupply.toString(),
                  label: 'Low Supply',
                  icon: Icons.warning_amber,
                  isWarning: lowSupply > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_ScheduleItem> _getTodaySchedule(List<MedicationModel> medications) {
    final List<_ScheduleItem> schedule = [];

    for (final med in medications) {
      if (!med.isActive) continue;

      for (final timeStr in med.scheduleTimes) {
        schedule.add(_ScheduleItem(medication: med, time: timeStr));
      }
    }

    // Sort by time
    schedule.sort((a, b) => a.time.compareTo(b.time));

    return schedule;
  }
}

class _ScheduleItem {
  final MedicationModel medication;
  final String time;

  _ScheduleItem({required this.medication, required this.time});
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isWarning;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isWarning ? Colors.yellow : Colors.white70, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: isWarning ? Colors.yellow : Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final MedicationModel medication;
  final String time;

  const _ScheduleCard({
    required this.medication,
    required this.time,
  });

  static const List<IconData> _icons = [
    Icons.medication,
    Icons.medical_services,
    Icons.healing,
    Icons.favorite,
    Icons.local_pharmacy,
    Icons.vaccines,
  ];

  @override
  Widget build(BuildContext context) {
    final iconData = medication.iconId < _icons.length
        ? _icons[medication.iconId]
        : Icons.medication;

    // Check if this time has passed
    final now = TimeOfDay.now();
    final parts = time.split(':');
    final scheduleTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final isPast = (scheduleTime.hour < now.hour) ||
        (scheduleTime.hour == now.hour && scheduleTime.minute < now.minute);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: medication.colorObj.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: medication.colorObj),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${medication.dosage} ${medication.dosageUnit}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPast ? Colors.grey : medication.colorObj,
                  ),
                ),
                if (isPast)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Done',
                      style:
                          TextStyle(fontSize: 10, color: Colors.green.shade700),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            if (!isPast)
              IconButton(
                icon: Icon(Icons.check_circle_outline,
                    color: medication.colorObj),
                onPressed: () {
                  Provider.of<MedicationProvider>(context, listen: false)
                      .decrementSupply(medication.medId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medication.name} taken!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
