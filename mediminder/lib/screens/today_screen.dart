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
    _loadAd();
  }

  void _loadAd() {
    final adProvider = Provider.of<AdProvider>(context);
    if (!adProvider.isPremium && _bannerAd == null) {
      _bannerAd = adProvider.createBanner(() {
        if (mounted) setState(() => _isAdLoaded = true);
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
            const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(dateFormat.format(now),
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal)),
          ],
        ),
        toolbarHeight: 70,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-med'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<MedicationProvider, DoseProvider>(
              builder: (context, medProvider, doseProvider, child) {
                if (medProvider.isLoading || doseProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (medProvider.medications.isEmpty) {
                  return _buildEmptyState(context);
                }

                final todayDoses = doseProvider.todayDoses;
                final takenCount =
                    todayDoses.where((d) => d.status == 'taken').length;
                final totalCount = todayDoses.length;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummaryCard(context, medProvider.medications,
                        takenCount, totalCount),
                    const SizedBox(height: 20),
                    Text("Today's Schedule",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (todayDoses.isEmpty)
                      _buildNoSchedule()
                    else
                      ...todayDoses.map((dose) {
                        final med = medProvider.medications.firstWhere(
                          (m) => m.medId == dose.medId,
                          orElse: () => MedicationModel(
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
                          ),
                        );
                        return _DoseCard(dose: dose, medication: med);
                      }),
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

  Widget _buildNoSchedule() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('No doses scheduled for today',
              style: TextStyle(color: Colors.grey.shade600)),
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
                color: const Color(0xFF1a237e).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_rounded,
                  size: 60, color: Color(0xFF1a237e)),
            ),
            const SizedBox(height: 24),
            Text('No medications yet',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Add a medication to start tracking',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-med'),
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, List<MedicationModel> meds, int taken, int total) {
    final lowSupply =
        meds.where((m) => m.currentSupply <= m.lowSupplyThreshold).length;
    final percent = total > 0 ? (taken / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.analytics_rounded,
                  color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text('Today\'s Progress',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: total > 0 ? taken / total : 0,
                            strokeWidth: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                        Text('$percent%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$taken of $total doses',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white24),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication, color: Colors.white70, size: 20),
                        const SizedBox(width: 4),
                        Text('${meds.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Text('Active Meds',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 12),
                    if (lowSupply > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber,
                              color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text('$lowSupply low supply',
                              style: const TextStyle(
                                  color: Colors.yellow, fontSize: 12)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoseCard extends StatelessWidget {
  final DoseLogModel dose;
  final MedicationModel medication;

  const _DoseCard({required this.dose, required this.medication});

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
    final isTaken = dose.status == 'taken';
    final isSkipped = dose.status == 'skipped';
    final isPast = dose.scheduledTime.isBefore(DateTime.now());
    final iconData = medication.iconId < _icons.length
        ? _icons[medication.iconId]
        : Icons.medication;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isTaken
            ? Colors.green.shade50
            : (isSkipped ? Colors.grey.shade100 : Theme.of(context).cardColor),
        borderRadius: BorderRadius.circular(16),
        border:
            isTaken ? Border.all(color: Colors.green.shade300, width: 2) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
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
                color: isTaken
                    ? Colors.green
                    : medication.colorObj.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isTaken
                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                  : Icon(iconData, color: medication.colorObj),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medication.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration:
                            isSkipped ? TextDecoration.lineThrough : null,
                      )),
                  Text('${medication.dosage} ${medication.dosageUnit}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(dose.scheduledTime),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTaken
                            ? Colors.green
                            : (isPast ? Colors.orange : Colors.grey.shade700))),
                if (isTaken)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('Taken ✓',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
                  )
                else if (isSkipped)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('Skipped',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600)),
                  ),
              ],
            ),
            if (!isTaken && !isSkipped)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Provider.of<DoseProvider>(context, listen: false)
                          .markAsSkipped(dose.medId, dose.scheduledTime);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.check_circle,
                        color: medication.colorObj, size: 32),
                    onPressed: () {
                      Provider.of<DoseProvider>(context, listen: false)
                          .markAsTaken(dose.medId, dose.scheduledTime);
                      Provider.of<MedicationProvider>(context, listen: false)
                          .decrementSupply(dose.medId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${medication.name} marked as taken! ✓'),
                            backgroundColor: Colors.green),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
