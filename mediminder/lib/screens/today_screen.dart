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
import '../themes/app_theme.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with Logo
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            color:
                theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
            child: Row(
              children: [
                // App Logo - Pill bottle icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset('Logo/Medi Minder Logo.png',
                      width: 26, height: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MediMinder',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer2<MedicationProvider, DoseProvider>(
              builder: (context, medProvider, doseProvider, child) {
                if (medProvider.medications.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }

                final doses = doseProvider.todayDoses;
                final taken = doses.where((d) => d.status == 'taken').length;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProgressCard(
                        taken, doses.length, medProvider.medications, theme),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Today's Schedule", theme),
                    const SizedBox(height: 12),
                    if (doses.isEmpty)
                      _buildAllDoneCard(theme)
                    else
                      ...doses.map((dose) => _DoseCard(
                            dose: dose,
                            medication: medProvider.medications.firstWhere(
                              (m) => m.medId == dose.medId,
                              orElse: () => _defaultMed(),
                            ),
                            isDark: isDark,
                          )),
                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ),

          // Banner Ad
          if (_isAdLoaded && _bannerAd != null)
            Container(
              width: double.infinity,
              height: _bannerAd!.size.height.toDouble(),
              color: theme.scaffoldBackgroundColor,
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-med'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        TextButton(
          onPressed: () => context.push('/add-med'),
          child: const Text('+ Add'),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
      int taken, int total, List<MedicationModel> meds, ThemeData theme) {
    final percent = total > 0 ? (taken / total * 100).round() : 100;
    final lowSupply =
        meds.where((m) => m.currentSupply <= m.lowSupplyThreshold).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: total > 0 ? taken / total : 1,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text('$percent%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
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
                const SizedBox(height: 4),
                Text('${meds.length} active medications',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                if (lowSupply > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('⚠️ $lowSupply low supply',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDoneCard(ThemeData theme) {
    bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle,
              size: 48,
              color: isDark ? Colors.greenAccent : Colors.green.shade400),
          const SizedBox(height: 8),
          Text('All done for today!',
              style: TextStyle(
                  color: isDark ? Colors.greenAccent : Colors.green,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset('Logo/Medi Minder Logo.png',
                  width: 40, height: 40),
            ),
            const SizedBox(height: 24),
            Text('No medications yet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Add your first medication to start tracking',
              style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-med'),
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
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
        color: AppTheme.primaryColor.value,
        createdAt: DateTime.now(),
      );
}

class _DoseCard extends StatelessWidget {
  final DoseLogModel dose;
  final MedicationModel medication;
  final bool isDark;
  const _DoseCard(
      {required this.dose, required this.medication, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isTaken = dose.status == 'taken';
    final isSkipped = dose.status == 'skipped';
    final theme = Theme.of(context);

    final medColor = Color(medication.color);

    // Icons mapping
    final List<IconData> icons = [
      Icons.medication,
      Icons.medical_services,
      Icons.healing,
      Icons.favorite,
      Icons.local_pharmacy,
      Icons.vaccines,
    ];
    final iconData =
        (medication.iconId >= 0 && medication.iconId < icons.length)
            ? icons[medication.iconId]
            : icons[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isTaken
              ? (isDark
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.green.shade200)
              : (isDark ? Colors.white10 : Colors.grey.shade200),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (isTaken) {
            _undo(context);
          } else {
            _take(context);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Habit Checkbox
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isTaken,
                  onChanged: (val) {
                    if (val == true) {
                      _take(context);
                    } else {
                      _undo(context);
                    }
                  },
                  shape: const CircleBorder(),
                  activeColor: AppTheme.primaryColor,
                  checkColor: Colors.white,
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: medColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: medColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: isTaken || isSkipped
                            ? TextDecoration.lineThrough
                            : null,
                        color: (isTaken || isSkipped)
                            ? theme.disabledColor
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage} ${medication.dosageUnit} • ${_formatTime(dose.scheduledTime)}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _take(BuildContext context) {
    Provider.of<DoseProvider>(context, listen: false)
        .markAsTaken(dose.medId, dose.scheduledTime);
    Provider.of<MedicationProvider>(context, listen: false)
        .decrementSupply(dose.medId);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${medication.name} taken'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green),
    );
  }

  void _undo(BuildContext context) {
    Provider.of<DoseProvider>(context, listen: false)
        .undoDose(dose.medId, dose.scheduledTime);
  }

  String _formatTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
  }
}
