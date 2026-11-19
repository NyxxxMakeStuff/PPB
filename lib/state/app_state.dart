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
  MealEntry get currentMeal => _currentMeal;

  List<WorkoutItem> get filteredWorkouts {
    if (_selectedWorkoutFilter == WorkoutCategory.semua) {
      return _workouts;
    }
    return _workouts.where((w) => w.category == _selectedWorkoutFilter).toList();
  }

  AppState() {
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

  Future<String?> register(String nama, String email, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await ApiService.register(nama: nama, email: email, password: password);
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
      final workoutLogs = await ApiService.getWorkoutLogs();
      _workouts.clear();
      int totalMinutes = 0;
      for (var item in workoutLogs) {
        if (item is Map<String, dynamic>) {
          final workoutItem = WorkoutItem.fromJson(item);
          _workouts.add(workoutItem);
          final dur = int.tryParse(item['durasi_menit']?.toString() ?? '0') ?? 0;
          totalMinutes += dur;
        }
      }
      _exerciseMinutes = totalMinutes;

      final nutritionLogs = await ApiService.getNutritionLogs();
      int totalKcal = 0;
      int totalProt = 0;
      for (var nLog in nutritionLogs) {
        if (nLog is Map<String, dynamic>) {
          final kcal = int.tryParse(nLog['total_kalori']?.toString() ?? '0') ?? 0;
          final prot = int.tryParse(nLog['total_protein']?.toString() ?? '0') ?? 0;
          totalKcal += kcal;
          totalProt += prot;
        }
      }
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

  Future<void> updateUserTargets({int? targetKcal, int? targetProteinG, int? weightKg, int? heightCm}) async {
    _userProfile = _userProfile.copyWith(
      targetKcal: targetKcal ?? _userProfile.targetKcal,
      targetProteinG: targetProteinG ?? _userProfile.targetProteinG,
      weightKg: weightKg ?? _userProfile.weightKg,
      heightCm: heightCm ?? _userProfile.heightCm,
    );
    notifyListeners();

    if (!_isGuestMode && _userProfile.id != null) {
      try {
        final Map<String, dynamic> body = {};
        if (heightCm != null) body['tinggi_cm'] = heightCm;
        if (targetKcal != null) body['target_kalori'] = targetKcal;
        if (targetProteinG != null) body['target_protein'] = targetProteinG;
        await ApiService.updateUserProfile(_userProfile.id!, body);

        if (weightKg != null) {
          final today = DateTime.now().toIso8601String().split('T').first;
          await ApiService.logBodyWeight(weightKg.toDouble(), today);
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

    if (!_isGuestMode) {
      try {
        await ApiService.createWorkoutLog(
          tanggal: todayStr,
          durasiMenit: durationMinutes,
          catatan: '$title - $subtitle',
        );
      } catch (e) {
        debugPrint('Failed to create workout log on server: $e');
      }
    }
  }

  Future<void> logMealAgain() async {
    _caloriesConsumed += _currentMeal.totalCalories;
    _proteinConsumed += _currentMeal.proteinG;
    _weeklyCalories['Kam'] = _caloriesConsumed;
    notifyListeners();

    if (!_isGuestMode) {
      try {
        final todayStr = DateTime.now().toIso8601String().split('T').first;
        await ApiService.createNutritionLog(
          tanggal: todayStr,
          waktuMakan: 'sarapan',
          totalKalori: _currentMeal.totalCalories,
          totalProtein: _currentMeal.proteinG,
        );
      } catch (e) {
        debugPrint('Failed to create nutrition log on server: $e');
      }
    }
  }

  void updateMeal(MealEntry meal) {
    _currentMeal = meal;
    notifyListeners();
  }
}
