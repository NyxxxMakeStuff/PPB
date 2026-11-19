import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class EditMealSheet extends StatefulWidget {
  final MealEntry meal;
  const EditMealSheet({super.key, required this.meal});

  @override
  State<EditMealSheet> createState() => _EditMealSheetState();
}

class _EditMealSheetState extends State<EditMealSheet> {
  late List<Ingredient> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = widget.meal.ingredients.map((e) => Ingredient(
      name: e.name,
      detail: e.detail,
      calories: e.calories,
    )).toList();
  }

  void _saveChanges() {
    final state = AppStateProvider.of(context);
    int newTotal = 0;
    for (var ing in _ingredients) {
      newTotal += ing.calories;
    }

    final updatedMeal = MealEntry(
      id: widget.meal.id,
      categoryTime: widget.meal.categoryTime,
      title: widget.meal.title,
      totalCalories: newTotal,
      portionInfo: widget.meal.portionInfo,
      estimateInfo: 'Estimasi dari ${_ingredients.length} bahan',
      proteinG: widget.meal.proteinG,
      carbsG: widget.meal.carbsG,
      fatG: widget.meal.fatG,
      ingredients: _ingredients,
    );

    state.updateMeal(updatedMeal);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jurnal nutrisi berhasil diperbarui!'),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Bahan ${widget.meal.title}',
            style: AppTheme.serifTitle(fontSize: 22),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _ingredients.length,
              itemBuilder: (ctx, idx) {
                final ing = _ingredients[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: TextEditingController(text: ing.name),
                          onChanged: (val) => ing.name = val,
                          decoration: const InputDecoration(hintText: 'Bahan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(text: ing.detail),
                          onChanged: (val) => ing.detail = val,
                          decoration: const InputDecoration(hintText: 'Porsi'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: TextEditingController(text: ing.calories.toString()),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => ing.calories = int.tryParse(val) ?? 0,
                          decoration: const InputDecoration(hintText: 'Kkal'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkCharcoal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
