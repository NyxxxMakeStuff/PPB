import 'package:flutter/material.dart';

class UserProfile {
  int? id;
  String name;
  String email;
  int weightKg;
  int heightCm;
  int targetKcal;
  int targetProteinG;
  int targetCarbsG;
  int targetFatG;
  String jenisKelamin;
  String tujuan;
  String levelAktivitas;
  String tanggalLahir;
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
    this.targetCarbsG = 250,
    this.targetFatG = 70,
    this.jenisKelamin = 'L',
    this.tujuan = 'maintain',
    this.levelAktivitas = 'moderate',
    this.tanggalLahir = '1995-05-12',
    this.cloudBackupEnabled = true,
    this.lastBackup = '21 Okt, 20.14',
    this.unitSystem = 'Metrik',
    this.workoutReminder = '06.30',
    this.exportFormat = 'CSV',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {int defaultWeight = 68}) {
    final userMap = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final heightVal = double.tryParse(userMap['tinggi_cm']?.toString() ?? '') ?? 172.0;
    final kcalVal = double.tryParse(userMap['target_kalori']?.toString() ?? '') ?? 2200.0;
    final protVal = double.tryParse(userMap['target_protein']?.toString() ?? '') ?? 120.0;
    final carbsVal = double.tryParse(userMap['target_karbo']?.toString() ?? '') ?? 250.0;
    final fatVal = double.tryParse(userMap['target_lemak']?.toString() ?? '') ?? 70.0;
    final idVal = userMap['id'] is int
        ? userMap['id'] as int
        : int.tryParse(userMap['id']?.toString() ?? '');

    return UserProfile(
      id: idVal,
      name: userMap['nama']?.toString() ?? userMap['name']?.toString() ?? 'Pengguna',
      email: userMap['email']?.toString() ?? '',
      weightKg: defaultWeight,
      heightCm: heightVal.round(),
      targetKcal: kcalVal.round(),
      targetProteinG: protVal.round(),
      targetCarbsG: carbsVal.round(),
      targetFatG: fatVal.round(),
      jenisKelamin: userMap['jenis_kelamin']?.toString() ?? 'L',
      tujuan: userMap['tujuan']?.toString() ?? 'maintain',
      levelAktivitas: userMap['level_aktivitas']?.toString() ?? 'moderate',
      tanggalLahir: userMap['tanggal_lahir']?.toString() ?? '1995-05-12',
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
    int? targetCarbsG,
    int? targetFatG,
    String? jenisKelamin,
    String? tujuan,
    String? levelAktivitas,
    String? tanggalLahir,
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
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatG: targetFatG ?? this.targetFatG,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tujuan: tujuan ?? this.tujuan,
      levelAktivitas: levelAktivitas ?? this.levelAktivitas,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
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
    final catStr = (json['kategori'] ?? json['category'] ?? '').toString().toLowerCase();
    final notes = json['catatan']?.toString() ?? json['title']?.toString() ?? 'Latihan';

    String title = notes;
    String subtitle = json['rincian']?.toString() ?? 'Sesi latihan';

    if (notes.contains(' - ')) {
      final parts = notes.split(' - ');
      title = parts[0];
      subtitle = parts.sublist(1).join(' - ');
    }

    final combinedStr = '$title $catStr'.toLowerCase();
    WorkoutCategory category = WorkoutCategory.beban;
    Color catColor = const Color(0xFF386B49);

    if (combinedStr.contains('kardio') ||
        combinedStr.contains('cardio') ||
        combinedStr.contains('lari') ||
        combinedStr.contains('running')) {
      category = WorkoutCategory.kardio;
      catColor = const Color(0xFFD89B33);
    } else if (combinedStr.contains('core') ||
        combinedStr.contains('plank') ||
        combinedStr.contains('abs')) {
      category = WorkoutCategory.core;
      catColor = const Color(0xFF3B6B77);
    }

    final duration = json['total_durasi_menit']?.toString() ??
        json['durasi_menit']?.toString() ??
        '15';

    String dateGroup = 'HARI INI';
    if (json['tanggal'] != null) {
      try {
        final dt = DateTime.parse(json['tanggal'].toString());
        final now = DateTime.now();
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          dateGroup = 'HARI INI';
        } else {
          final days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
          dateGroup = '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month - 1]}';
        }
      } catch (_) {}
    } else if (json['tanggal_group'] != null) {
      dateGroup = json['tanggal_group'].toString();
    }

    return WorkoutItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: json['waktu']?.toString() ?? '07.00',
      title: title,
      subtitle: json['rincian']?.toString() ?? subtitle,
      value: json['nilai']?.toString() ?? '$duration mnt',
      category: category,
      categoryColor: catColor,
      dateGroup: dateGroup,
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
