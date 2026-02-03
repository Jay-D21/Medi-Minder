import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../providers/ad_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/dose_provider.dart';
import '../models/medication_model.dart';
import '../models/dose_log_model.dart';

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
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adProvider = Provider.of<AdProvider>(context);
    if (!adProvider.isPremium && _bannerAd == null) {
      _bannerAd = adProvider.createBanner(() {
        if (mounted) setState(() => _isAdLoaded = true);
      });
      _bannerAd?.load();
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today'),
            Text(DateFormat('EEEE, MMM d').format(now),
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        toolbarHeight: 65,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-med'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<MedicationProvider, DoseProvider>(
              builder: (context, medProvider, doseProvider, child) {
                if (medProvider.medications.isEmpty) {
                  return _EmptyState(onAdd: () => context.push('/add-med'));
                }

                final doses = doseProvider.todayDoses;
                final taken = doses.where((d) => d.status == 'taken').length;
                final total = doses.length;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Progress Card
                    _ProgressCard(
                        taken: taken,
                        total: total,
                        lowSupply: medProvider.medications
                            .where(
                                (m) => m.currentSupply <= m.lowSupplyThreshold)
                            .length),
                    const SizedBox(height: 20),

                    // Schedule
                    Text("Schedule",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    if (doses.isEmpty)
                      const _NoScheduleCard()
                    else
                      ...doses.map((dose) => _DoseItem(
                            dose: dose,
                            medication: medProvider.medications.firstWhere(
                              (m) => m.medId == dose.medId,
                              orElse: () => _defaultMed(),
                            ),
                          )),
                  ],
                );
              },
            ),
          ),

          // Banner Ad
          if (_isAdLoaded && _bannerAd != null)
            SafeArea(
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  MedicationModel _defaultMed() => MedicationModel(
        medId: '',
        userId: '',
        name: 'Unknown',
        dosage: 0,
        dosageUnit: '',
        frequencyType: '',
        scheduleTimes: [],
        iconId: 0,
        color: 0xFF1a237e,
        createdAt: DateTime.now(),
      );
}

class _ProgressCard extends StatelessWidget {
  final int taken, total, lowSupply;
  const _ProgressCard(
      {required this.taken, required this.total, required this.lowSupply});

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (taken / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1a237e), Color(0xFF3949ab)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: total > 0 ? taken / total : 0,
                  strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text('$percent%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$taken of $total doses taken',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                if (lowSupply > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('⚠️ $lowSupply low supply',
                        style: const TextStyle(
                            color: Colors.yellow, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseItem extends StatelessWidget {
  final DoseLogModel dose;
  final MedicationModel medication;
  const _DoseItem({required this.dose, required this.medication});

  static const _icons = [
    Icons.medication,
    Icons.medical_services,
    Icons.healing,
    Icons.favorite,
    Icons.local_pharmacy,
    Icons.vaccines
  ];

  @override
  Widget build(BuildContext context) {
    final isTaken = dose.status == 'taken';
    final icon = medication.iconId < _icons.length
        ? _icons[medication.iconId]
        : Icons.medication;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isTaken ? Colors.green.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isTaken ? Colors.green : medication.colorObj.withAlpha(50),
          child: Icon(isTaken ? Icons.check : icon,
              color: isTaken ? Colors.white : medication.colorObj),
        ),
        title: Text(medication.name,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: dose.status == 'skipped'
                    ? TextDecoration.lineThrough
                    : null)),
        subtitle: Text(
            '${medication.dosage} ${medication.dosageUnit} • ${_formatTime(dose.scheduledTime)}'),
        trailing: isTaken
            ? const Chip(
                label: Text('Done', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _skip(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.check_circle,
                        color: medication.colorObj, size: 28),
                    onPressed: () => _take(context),
                  ),
                ],
              ),
      ),
    );
  }

  void _take(BuildContext context) {
    Provider.of<DoseProvider>(context, listen: false)
        .markAsTaken(dose.medId, dose.scheduledTime);
    Provider.of<MedicationProvider>(context, listen: false)
        .decrementSupply(dose.medId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${medication.name} taken ✓'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2)));
  }

  void _skip(BuildContext context) {
    Provider.of<DoseProvider>(context, listen: false)
        .markAsSkipped(dose.medId, dose.scheduledTime);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${medication.name} skipped'),
        duration: const Duration(seconds: 2)));
  }

  String _formatTime(DateTime t) =>
      '${t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour)}:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
}

class _NoScheduleCard extends StatelessWidget {
  const _NoScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('No doses scheduled',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: const Color(0xFF1a237e).withAlpha(25),
                  shape: BoxShape.circle),
              child: const Icon(Icons.medication_rounded,
                  size: 48, color: Color(0xFF1a237e)),
            ),
            const SizedBox(height: 24),
            const Text('No medications yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Add your first medication to get started',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Medication')),
          ],
        ),
      ),
    );
  }
}
