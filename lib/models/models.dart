import 'package:flutter/material.dart';

class UserProfile {
  int? id;
  String name;
  String email;
  int weightKg;
  int heightCm;
  int targetKcal;
  int targetProteinG;
  bool cloudBackupEnabled;
  String lastBackup;
  String unitSystem;
  String workoutReminder;
  String exportFormat;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.weightKg,
    required this.heightCm,
    required this.targetKcal,
    required this.targetProteinG,
    this.cloudBackupEnabled = true,
    this.lastBackup = '21 Okt, 20.14',
    this.unitSystem = 'Metrik',
    this.workoutReminder = '06.30',
    this.exportFormat = 'CSV',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {int defaultWeight = 68}) {
    final heightVal = double.tryParse(json['tinggi_cm']?.toString() ?? '') ?? 172.0;
    final kcalVal = double.tryParse(json['target_kalori']?.toString() ?? '') ?? 2600.0;
    final protVal = double.tryParse(json['target_protein']?.toString() ?? '') ?? 130.0;

    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['nama']?.toString() ?? json['name']?.toString() ?? 'Dimas Pratama',
      email: json['email']?.toString() ?? 'dimas@email.com',
      weightKg: defaultWeight,
      heightCm: heightVal.round(),
      targetKcal: kcalVal.round(),
      targetProteinG: protVal.round(),
      cloudBackupEnabled: true,
      lastBackup: 'Terhubung ke server',
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    int? weightKg,
    int? heightCm,
    int? targetKcal,
    int? targetProteinG,
    bool? cloudBackupEnabled,
    String? lastBackup,
    String? unitSystem,
    String? workoutReminder,
    String? exportFormat,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      targetKcal: targetKcal ?? this.targetKcal,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
      lastBackup: lastBackup ?? this.lastBackup,
      unitSystem: unitSystem ?? this.unitSystem,
      workoutReminder: workoutReminder ?? this.workoutReminder,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }
}

enum WorkoutCategory { semua, beban, kardio, core }

class WorkoutItem {
  final String id;
  final String time;
  final String title;
  final String subtitle;
  final String value;
  final WorkoutCategory category;
  final Color categoryColor;
  final String dateGroup;

  WorkoutItem({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.category,
    required this.categoryColor,
    required this.dateGroup,
  });

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    final catStr = (json['kategori'] ?? json['category'] ?? 'beban').toString().toLowerCase();
    WorkoutCategory category = WorkoutCategory.beban;
    Color catColor = const Color(0xFF386B49);

    if (catStr.contains('kardio') || catStr.contains('cardio')) {
      category = WorkoutCategory.kardio;
      catColor = const Color(0xFFD89B33);
    } else if (catStr.contains('core')) {
      category = WorkoutCategory.core;
      catColor = const Color(0xFF3B6B77);
    }

    final duration = json['durasi_menit']?.toString() ?? '15';

    return WorkoutItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: json['waktu']?.toString() ?? '07.00',
      title: json['nama']?.toString() ?? json['title']?.toString() ?? 'Latihan',
      subtitle: json['rincian']?.toString() ?? json['catatan']?.toString() ?? '$duration mnt sesi',
      value: json['nilai']?.toString() ?? '$duration mnt',
      category: category,
      categoryColor: catColor,
      dateGroup: json['tanggal_group']?.toString() ?? 'HARI INI',
    );
  }
}

class Ingredient {
  String name;
  String detail;
  int calories;

  Ingredient({
    required this.name,
    required this.detail,
    required this.calories,
  });
}

class MealEntry {
  final String id;
  final String categoryTime;
  final String title;
  int totalCalories;
  final String portionInfo;
  final String estimateInfo;
  int proteinG;
  int carbsG;
  int fatG;
  List<Ingredient> ingredients;

  MealEntry({
    required this.id,
    required this.categoryTime,
    required this.title,
    required this.totalCalories,
    required this.portionInfo,
    required this.estimateInfo,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.ingredients,
  });
}
