import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isGuestMode = false;
  String? _authError;

  UserProfile _userProfile = UserProfile(
    name: 'Pengguna',
    email: '',
    weightKg: 68,
    heightCm: 172,
    targetKcal: 2600,
    targetProteinG: 130,
  );

  int _caloriesConsumed = 0;
  int _proteinConsumed = 0;
  int _exerciseMinutes = 0;

  WorkoutCategory _selectedWorkoutFilter = WorkoutCategory.semua;

  final Map<String, int> _weeklyCalories = {
    'Sen': 0,
    'Sel': 0,
    'Rab': 0,
    'Kam': 0,
    'Jum': 0,
    'Sab': 0,
    'Min': 0,
  };

  final List<WorkoutItem> _workouts = [];

  final List<MealEntry> _meals = [
    MealEntry(
      id: 'm1',
      categoryTime: 'SARAPAN · 07.15',
      title: 'Oatmeal & Telur Rebus',
      totalCalories: 450,
      portionInfo: '1 porsi · 250g',
      estimateInfo: 'Pencatatan mandiri',
      proteinG: 25,
      carbsG: 50,
      fatG: 12,
      ingredients: [
        Ingredient(name: 'Oatmeal', detail: '50g', calories: 150),
        Ingredient(name: 'Telur Rebus', detail: '2 butir', calories: 140),
        Ingredient(name: 'Susu Low Fat', detail: '200ml', calories: 160),
      ],
    ),
    MealEntry(
      id: 'm2',
      categoryTime: 'SIANG · 12.30',
      title: 'Nasi Merah & Dada Ayam Grill',
      totalCalories: 600,
      portionInfo: '1 porsi · 350g',
      estimateInfo: 'Pencatatan mandiri',
      proteinG: 45,
      carbsG: 65,
      fatG: 10,
      ingredients: [
        Ingredient(name: 'Nasi Merah', detail: '150g', calories: 170),
        Ingredient(name: 'Dada Ayam Grill', detail: '150g', calories: 250),
        Ingredient(name: 'Sayur Bayam & Brokoli', detail: '100g', calories: 80),
        Ingredient(name: 'Minyak Zaitun', detail: '1 sdt', calories: 100),
      ],
    ),
  ];

  MealEntry _currentMeal = MealEntry(
    id: 'm1',
    categoryTime: 'SARAPAN · 07.15',
    title: 'Menu Harian',
    totalCalories: 550,
    portionInfo: '1 porsi',
    estimateInfo: 'Pencatatan mandiri',
    proteinG: 30,
    carbsG: 60,
    fatG: 18,
    ingredients: [
      Ingredient(name: 'Makanan Utama', detail: '1 porsi', calories: 550),
    ],
  );

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isGuestMode => _isGuestMode;
  String? get authError => _authError;
  UserProfile get userProfile => _userProfile;
  int get caloriesConsumed => _caloriesConsumed;
  int get proteinConsumed => _proteinConsumed;
  int get exerciseMinutes => _exerciseMinutes;
  int get remainingCalories => (_userProfile.targetKcal - _caloriesConsumed).clamp(0, 99999);
  WorkoutCategory get selectedWorkoutFilter => _selectedWorkoutFilter;
  Map<String, int> get weeklyCalories => _weeklyCalories;
  List<MealEntry> get meals => _meals;
  MealEntry get currentMeal => _meals.isNotEmpty ? _meals.first : _currentMeal;

  List<WorkoutItem> get filteredWorkouts {
    if (_selectedWorkoutFilter == WorkoutCategory.semua) {
      return _workouts;
    }
    return _workouts.where((w) => w.category == _selectedWorkoutFilter).toList();
  }

  AppState() {
    _recalculateTotals();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await ApiService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final userJson = await ApiService.getMe();
        _userProfile = UserProfile.fromJson(userJson, defaultWeight: _userProfile.weightKg);
        _isLoggedIn = true;
        _isGuestMode = false;
        await refreshDataFromApi();
      } catch (_) {
        await ApiService.clearTokens();
      }
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await ApiService.login(email, password);
      final userJson = await ApiService.getMe();
      _userProfile = UserProfile.fromJson(userJson, defaultWeight: _userProfile.weightKg);
      _isLoggedIn = true;
      _isGuestMode = false;
      await refreshDataFromApi();
      return null;
    } on ApiException catch (e) {
      _authError = e.message;
      return e.message;
    } catch (e) {
      _authError = 'Gagal terhubung ke server backend API.';
      return _authError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(
    String nama,
    String email,
    String password, {
    String jenisKelamin = 'L',
    String tujuan = 'maintain',
    int targetKalori = 2200,
    double targetProtein = 120.0,
    double targetKarbo = 250.0,
    double targetLemak = 70.0,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final displayName = nama.trim().isNotEmpty ? nama.trim() : email.split('@').first;
      await ApiService.register(
        nama: displayName,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        tujuan: tujuan,
        targetKalori: targetKalori,
        targetProtein: targetProtein,
        targetKarbo: targetKarbo,
        targetLemak: targetLemak,
      );
      final userJson = await ApiService.getMe();
      _userProfile = UserProfile.fromJson(userJson, defaultWeight: _userProfile.weightKg);
      _isLoggedIn = true;
      _isGuestMode = false;
      await refreshDataFromApi();
      return null;
    } on ApiException catch (e) {
      _authError = e.message;
      return e.message;
    } catch (e) {
      _authError = 'Gagal mendaftar ke server backend API.';
      return _authError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loginAsGuest() {
    _isLoggedIn = true;
    _isGuestMode = true;
    _userProfile = UserProfile(
      name: 'Pengguna',
      email: 'tamu@fitjournal.local',
      weightKg: 68,
      heightCm: 172,
      targetKcal: 2600,
      targetProteinG: 130,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    if (!_isGuestMode) {
      await ApiService.logout();
    }
    _isLoggedIn = false;
    _isGuestMode = false;
    _workouts.clear();
    _caloriesConsumed = 0;
    _proteinConsumed = 0;
    _exerciseMinutes = 0;
    notifyListeners();
  }

  Future<void> refreshDataFromApi() async {
    if (_isGuestMode) return;
    try {
      // 1. Refresh profile info
      try {
        final userJson = await ApiService.getMe();
        _userProfile = UserProfile.fromJson(userJson, defaultWeight: _userProfile.weightKg);
      } catch (_) {}

      // 2. Refresh weight logs
      try {
        final weightLogs = await ApiService.getBodyWeightLogs();
        if (weightLogs.isNotEmpty) {
          final lastLog = weightLogs.last;
          if (lastLog is Map<String, dynamic> && lastLog['berat_kg'] != null) {
            final wVal = double.tryParse(lastLog['berat_kg'].toString());
            if (wVal != null) {
              _userProfile = _userProfile.copyWith(weightKg: wVal.round());
            }
          }
        }
      } catch (_) {}

      // 3. Refresh workout logs
      final workoutLogs = await ApiService.getWorkoutLogs();
      _workouts.clear();
      int totalMinutes = 0;
      for (var item in workoutLogs) {
        if (item is Map<String, dynamic>) {
          final workoutItem = WorkoutItem.fromJson(item);
          _workouts.add(workoutItem);
          final dur = int.tryParse(item['total_durasi_menit']?.toString() ?? item['durasi_menit']?.toString() ?? '0') ?? 0;
          totalMinutes += dur;
        }
      }
      _exerciseMinutes = totalMinutes;

      // 4. Refresh nutrition logs & items
      int totalKcal = 0;
      int totalProt = 0;

      try {
        final items = await ApiService.getNutritionLogItems();
        if (items.isNotEmpty) {
          for (var it in items) {
            if (it is Map<String, dynamic>) {
              final kcal = double.tryParse(it['kalori']?.toString() ?? '0') ?? 0;
              final prot = double.tryParse(it['protein_g']?.toString() ?? '0') ?? 0;
              totalKcal += kcal.round();
              totalProt += prot.round();
            }
          }
        }
      } catch (_) {}

      _caloriesConsumed = totalKcal;
      _proteinConsumed = totalProt;
      _weeklyCalories['Kam'] = _caloriesConsumed;
    } catch (e) {
      debugPrint('Error fetching data from backend API: $e');
    }
    notifyListeners();
  }

  void setWorkoutFilter(WorkoutCategory category) {
    _selectedWorkoutFilter = category;
    notifyListeners();
  }

  void toggleCloudBackup(bool value) {
    _userProfile = _userProfile.copyWith(cloudBackupEnabled: value);
    notifyListeners();
  }

  void triggerBackupNow() {
    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final timeStr = '${now.day} ${monthNames[now.month - 1]}, ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    _userProfile = _userProfile.copyWith(lastBackup: timeStr);
    notifyListeners();
  }

  Future<void> updateUserTargets({
    int? targetKcal,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    int? weightKg,
    int? heightCm,
    String? jenisKelamin,
    String? tujuan,
  }) async {
    _userProfile = _userProfile.copyWith(
      targetKcal: targetKcal ?? _userProfile.targetKcal,
      targetProteinG: targetProteinG ?? _userProfile.targetProteinG,
      targetCarbsG: targetCarbsG ?? _userProfile.targetCarbsG,
      targetFatG: targetFatG ?? _userProfile.targetFatG,
      weightKg: weightKg ?? _userProfile.weightKg,
      heightCm: heightCm ?? _userProfile.heightCm,
      jenisKelamin: jenisKelamin ?? _userProfile.jenisKelamin,
      tujuan: tujuan ?? _userProfile.tujuan,
    );
    notifyListeners();

    if (!_isGuestMode && _userProfile.id != null) {
      try {
        final Map<String, dynamic> updateData = {};
        if (heightCm != null) updateData['tinggi_cm'] = heightCm;
        if (targetKcal != null) updateData['target_kalori'] = targetKcal;
        if (targetProteinG != null) updateData['target_protein'] = targetProteinG;
        if (targetCarbsG != null) updateData['target_karbo'] = targetCarbsG;
        if (targetFatG != null) updateData['target_lemak'] = targetFatG;
        if (jenisKelamin != null) updateData['jenis_kelamin'] = jenisKelamin;
        if (tujuan != null) updateData['tujuan'] = tujuan;
        
        if (updateData.isNotEmpty) {
          await ApiService.updateUserProfile(_userProfile.id!, updateData);
        }

        if (weightKg != null) {
          final today = DateTime.now().toIso8601String().split('T').first;
          await ApiService.logBodyWeight(_userProfile.id!, weightKg.toDouble(), today);
        }
      } catch (e) {
        debugPrint('Failed to sync profile update to server: $e');
      }
    }
  }

  void updateUserSettings({String? unitSystem, String? workoutReminder, String? exportFormat}) {
    _userProfile = _userProfile.copyWith(
      unitSystem: unitSystem ?? _userProfile.unitSystem,
      workoutReminder: workoutReminder ?? _userProfile.workoutReminder,
      exportFormat: exportFormat ?? _userProfile.exportFormat,
    );
    notifyListeners();
  }

  Future<void> addWorkout({
    required String title,
    required String subtitle,
    required String value,
    required WorkoutCategory category,
    int durationMinutes = 15,
  }) async {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    final todayStr = now.toIso8601String().split('T').first;

    Color catColor = const Color(0xFF386B49);
    if (category == WorkoutCategory.kardio) catColor = const Color(0xFFD89B33);
    if (category == WorkoutCategory.core) catColor = const Color(0xFF3B6B77);

    final newItem = WorkoutItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: timeStr,
      title: title,
      subtitle: subtitle,
      value: value,
      category: category,
      categoryColor: catColor,
      dateGroup: 'HARI INI',
    );

    _workouts.insert(0, newItem);
    _exerciseMinutes += durationMinutes;
    notifyListeners();

    if (!_isGuestMode && _userProfile.id != null) {
      try {
        await ApiService.createWorkoutLog(
          _userProfile.id!,
          todayStr,
          durationMinutes,
          totalKaloriTerbakar: (durationMinutes * 7.0),
          catatan: '$title - $subtitle',
        );
      } catch (e) {
        debugPrint('Failed to create workout log on server: $e');
      }
    }
  }

  void _recalculateTotals() {
    int kcal = 0;
    int prot = 0;
    for (var m in _meals) {
      kcal += m.totalCalories;
      prot += m.proteinG;
    }
    _caloriesConsumed = kcal;
    _proteinConsumed = prot;
    _weeklyCalories['Kam'] = _caloriesConsumed;
  }

  Future<void> addMeal(MealEntry meal) async {
    _meals.insert(0, meal);
    _currentMeal = meal;
    _recalculateTotals();
    notifyListeners();

    if (!_isGuestMode && _userProfile.id != null) {
      try {
        String waktuMakan = 'sarapan';
        final lowerCat = meal.categoryTime.toLowerCase();
        if (lowerCat.contains('siang')) {
          waktuMakan = 'siang';
        } else if (lowerCat.contains('malam')) {
          waktuMakan = 'malam';
        } else if (lowerCat.contains('snack')) {
          waktuMakan = 'snack';
        }

        final todayStr = DateTime.now().toIso8601String().split('T').first;
        final res = await ApiService.createNutritionLog(
          _userProfile.id!,
          todayStr,
          waktuMakan,
        );

        final Map<String, dynamic> logData = (res['data'] is Map<String, dynamic>)
            ? res['data'] as Map<String, dynamic>
            : res;
        final logId = logData['id'] is int ? logData['id'] as int : int.tryParse(logData['id']?.toString() ?? '');

        if (logId != null && meal.ingredients.isNotEmpty) {
          try {
            final foods = await ApiService.getFoods();
            int foodId = 1;
            if (foods.isNotEmpty && foods[0] is Map && foods[0]['id'] != null) {
              foodId = int.tryParse(foods[0]['id'].toString()) ?? 1;
            } else {
              try {
                final newFoodRes = await ApiService.createFood(nama: meal.title);
                final foodData = (newFoodRes['data'] is Map<String, dynamic>)
                    ? newFoodRes['data'] as Map<String, dynamic>
                    : newFoodRes;
                foodId = int.tryParse(foodData['id']?.toString() ?? '') ?? 1;
              } catch (_) {}
            }

            await ApiService.createNutritionLogItem(
              logId,
              foodId,
              100.0,
              meal.totalCalories.toDouble(),
              meal.proteinG.toDouble(),
              carbsG: meal.carbsG.toDouble(),
              fatG: meal.fatG.toDouble(),
            );
          } catch (e) {
            debugPrint('Failed to create nutrition log item on server: $e');
          }
        }
      } catch (e) {
        debugPrint('Failed to create nutrition log on server: $e');
      }
    }
  }

  Future<void> updateMeal(MealEntry meal) async {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
    } else {
      _meals.insert(0, meal);
    }
    _currentMeal = meal;
    _recalculateTotals();
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((m) => m.id == id);
    _recalculateTotals();
    notifyListeners();

    if (!_isGuestMode) {
      try {
        final numericId = int.tryParse(id);
        if (numericId != null) {
          await ApiService.deleteNutritionLog(numericId);
        }
      } catch (e) {
        debugPrint('Failed to delete nutrition log on server: $e');
      }
    }
  }

  Future<void> logMealAgain([MealEntry? meal]) async {
    final targetMeal = meal ?? currentMeal;
    final duplicated = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryTime: targetMeal.categoryTime,
      title: '${targetMeal.title} (Lagi)',
      totalCalories: targetMeal.totalCalories,
      portionInfo: targetMeal.portionInfo,
      estimateInfo: targetMeal.estimateInfo,
      proteinG: targetMeal.proteinG,
      carbsG: targetMeal.carbsG,
      fatG: targetMeal.fatG,
      ingredients: targetMeal.ingredients.map((i) => Ingredient(name: i.name, detail: i.detail, calories: i.calories)).toList(),
    );
    await addMeal(duplicated);
  }
}
