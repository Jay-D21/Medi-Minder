import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 1)
class MedicationModel extends HiveObject {
  @HiveField(0)
  final String medId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double dosage;

  @HiveField(4)
  final String dosageUnit;

  @HiveField(5)
  final String frequencyType; // 'daily', 'weekly', 'interval', 'specific_days'

  @HiveField(6)
  final List<String> scheduleTimes; // Stored as "HH:mm" strings

  @HiveField(7)
  final int iconId;

  @HiveField(8)
  final int color; // Store color as int value

  @HiveField(9)
  int currentSupply;

  @HiveField(10)
  final int lowSupplyThreshold;

  @HiveField(11)
  bool isActive;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final List<int>?
      specificDays; // 1-7 for Mon-Sun, used if frequencyType is 'specific_days'

  @HiveField(14)
  final int? intervalDays; // Used if frequencyType is 'interval'

  MedicationModel({
    required this.medId,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.frequencyType,
    required this.scheduleTimes,
    required this.iconId,
    required this.color,
    this.currentSupply = 0,
    this.lowSupplyThreshold = 10,
    this.isActive = true,
    required this.createdAt,
    this.specificDays,
    this.intervalDays,
  });

  Color get colorObj => Color(color);

  MedicationModel copyWith({
    String? medId,
    String? userId,
    String? name,
    double? dosage,
    String? dosageUnit,
    String? frequencyType,
    List<String>? scheduleTimes,
    int? iconId,
    int? color,
    int? currentSupply,
    int? lowSupplyThreshold,
    bool? isActive,
    DateTime? createdAt,
    List<int>? specificDays,
    int? intervalDays,
  }) {
    return MedicationModel(
      medId: medId ?? this.medId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequencyType: frequencyType ?? this.frequencyType,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      iconId: iconId ?? this.iconId,
      color: color ?? this.color,
      currentSupply: currentSupply ?? this.currentSupply,
      lowSupplyThreshold: lowSupplyThreshold ?? this.lowSupplyThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      specificDays: specificDays ?? this.specificDays,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }
}
