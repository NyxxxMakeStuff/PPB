import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/edit_meal_sheet.dart';
import '../widgets/add_food_sheet.dart';

class NutritionScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const NutritionScreen({super.key, this.onBack});

  void _openEditMealSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditMealSheet(meal: state.currentMeal),
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

  void _logMealAgain(BuildContext context, AppState state) {
    state.logMealAgain();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Catatan "${state.currentMeal.title}" (+${state.currentMeal.totalCalories} kkal) ditambahkan ke hari ini!',
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final meal = state.currentMeal;

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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu opsi jurnal nutrisi'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle category & time
              Text(
                meal.categoryTime,
                style: AppTheme.uppercaseSubHeader(fontSize: 12),
              ),
              const SizedBox(height: 6),
              // Meal Title
              Text(
                meal.title,
                style: AppTheme.serifTitle(fontSize: 28),
              ),
              const SizedBox(height: 20),

              // Total Calories Row & info
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${meal.totalCalories}',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkCharcoal,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'kkal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        meal.portionInfo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meal.estimateInfo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Macro Bar Chart
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: [
                      // Protein segment (Green)
                      Expanded(
                        flex: meal.proteinG > 0 ? meal.proteinG : 1,
                        child: Container(color: AppColors.greenIndicator),
                      ),
                      const SizedBox(width: 3),
                      // Carbs segment (Yellow)
                      Expanded(
                        flex: meal.carbsG > 0 ? meal.carbsG : 1,
                        child: Container(color: AppColors.yellowIndicator),
                      ),
                      const SizedBox(width: 3),
                      // Fat segment (Orange)
                      Expanded(
                        flex: meal.fatG > 0 ? meal.fatG : 1,
                        child: Container(color: AppColors.accentOrange),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Macro Dot Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMacroLegend('Protein', '${meal.proteinG} g', AppColors.greenIndicator),
                  _buildMacroLegend('Karbohidrat', '${meal.carbsG} g', AppColors.yellowIndicator),
                  _buildMacroLegend('Lemak', '${meal.fatG} g', AppColors.accentOrange),
                ],
              ),
              const SizedBox(height: 32),

              // Section: Bahan & count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bahan',
                    style: AppTheme.serifTitle(fontSize: 22),
                  ),
                  Text(
                    '${meal.ingredients.length} item',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ingredients List
              if (meal.ingredients.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada bahan makanan tercatat.\nTekan tombol (+) di atas untuk menambah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                )
              else
                ...meal.ingredients.map((ing) => _buildIngredientRow(ing)),

              const SizedBox(height: 8),
              // Divider & Total row
              Container(height: 1.2, color: AppColors.darkCharcoal),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  Text(
                    '${meal.totalCalories} kkal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Bottom Action Buttons: Edit & Catat lagi hari ini
              Row(
                children: [
                  // Edit Button
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _openEditMealSheet(context, state),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkCharcoal, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.darkCharcoal),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.darkCharcoal,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Catat lagi hari ini Button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _logMealAgain(context, state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkCharcoal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Catat lagi hari ini',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
          '$label\n',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(Ingredient ing) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ing.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                ing.detail,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            '${ing.calories}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
