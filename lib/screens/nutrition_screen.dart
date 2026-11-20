import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/edit_meal_sheet.dart';
import '../widgets/add_food_sheet.dart';

class NutritionScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const NutritionScreen({super.key, this.onBack});

  void _openEditMealSheet(BuildContext context, AppState state, MealEntry meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditMealSheet(meal: meal),
    );
  }

  void _openAddFoodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddFoodSheet(),
    );
  }

  void _logMealAgain(BuildContext context, AppState state, MealEntry meal) async {
    await state.logMealAgain(meal);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Catatan "${meal.title}" (+${meal.totalCalories} kkal) ditambahkan ke hari ini!',
          ),
          backgroundColor: AppColors.darkCharcoal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteMeal(BuildContext context, AppState state, MealEntry meal) async {
    await state.deleteMeal(meal.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${meal.title}" berhasil dihapus.'),
          backgroundColor: AppColors.darkCharcoal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final meals = state.meals;

    // Calculate total macros across all meals
    int totalKcal = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    for (var m in meals) {
      totalKcal += m.totalCalories;
      totalProtein += m.proteinG;
      totalCarbs += m.carbsG;
      totalFat += m.fatG;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBack,
              )
            : null,
        title: const Text('Jurnal nutrisi'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26, color: AppColors.accentOrange),
            tooltip: 'Tambah Makanan',
            onPressed: () => _openAddFoodSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL ASUPAN HARI INI',
                      style: AppTheme.uppercaseSubHeader(fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalKcal',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'kkal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${meals.length} menu tercatat',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Segmented Macro Bar Chart
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 12,
                        child: Row(
                          children: [
                            Expanded(
                              flex: totalProtein > 0 ? totalProtein : 1,
                              child: Container(color: AppColors.greenIndicator),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              flex: totalCarbs > 0 ? totalCarbs : 1,
                              child: Container(color: AppColors.yellowIndicator),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              flex: totalFat > 0 ? totalFat : 1,
                              child: Container(color: AppColors.accentOrange),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Macro Dot Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMacroLegend('Protein', '$totalProtein g', AppColors.greenIndicator),
                        _buildMacroLegend('Karbohidrat', '$totalCarbs g', AppColors.yellowIndicator),
                        _buildMacroLegend('Lemak', '$totalFat g', AppColors.accentOrange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section Header: Daftar Makanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Makanan',
                    style: AppTheme.serifTitle(fontSize: 22),
                  ),
                  Text(
                    '${meals.length} item',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Meals List (CRUD items)
              if (meals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      'Belum ada catatan makanan.\nTekan tombol (+) di atas untuk menambah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                )
              else
                ...meals.map((meal) => _buildMealCard(context, state, meal)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroLegend(String label, String value, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, AppState state, MealEntry meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal.categoryTime,
                style: AppTheme.uppercaseSubHeader(fontSize: 11),
              ),
              Row(
                children: [
                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.darkCharcoal),
                    tooltip: 'Edit Makanan',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => _openEditMealSheet(context, state, meal),
                  ),
                  const SizedBox(width: 12),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    tooltip: 'Hapus Makanan',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => _deleteMeal(context, state, meal),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meal.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${meal.totalCalories} kkal · P: ${meal.proteinG}g · K: ${meal.carbsG}g · L: ${meal.fatG}g',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
              Text(
                meal.portionInfo,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          // Ingredients summary
          if (meal.ingredients.isNotEmpty)
            ...meal.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '• ${ing.name} (${ing.detail})',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${ing.calories} kkal',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 12),
          // Quick action: Catat lagi
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () => _logMealAgain(context, state, meal),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.darkCharcoal, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, size: 16, color: AppColors.darkCharcoal),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Catat lagi hari ini',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkCharcoal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
