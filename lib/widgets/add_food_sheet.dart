import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _portionController = TextEditingController(text: '1 porsi');
  String _waktuMakan = 'sarapan';

  void _saveFood() {
    final title = _titleController.text.trim();
    final kcal = int.tryParse(_caloriesController.text.trim()) ?? 0;
    final protein = int.tryParse(_proteinController.text.trim()) ?? 0;

    if (title.isEmpty || kcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan nama makanan dan jumlah kalori yang valid.'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    final state = AppStateProvider.of(context);
    
    final newMeal = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryTime: '${_waktuMakan.toUpperCase()} · ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      title: title,
      totalCalories: kcal,
      portionInfo: _portionController.text.trim(),
      estimateInfo: 'Pencatatan mandiri',
      proteinG: protein,
      carbsG: (kcal * 0.4 / 4).round(),
      fatG: (kcal * 0.3 / 9).round(),
      ingredients: [
        Ingredient(name: title, detail: _portionController.text.trim(), calories: kcal),
      ],
    );

    state.updateMeal(newMeal);
    state.logMealAgain();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Makanan "$title" ($kcal kkal) berhasil dicatat!'),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _portionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              'Tambah Jurnal Makanan',
              style: AppTheme.serifTitle(fontSize: 22),
            ),
            const SizedBox(height: 20),

            const Text('Waktu Makan', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMealTimeChip('Sarapan', 'sarapan'),
                const SizedBox(width: 8),
                _buildMealTimeChip('Siang', 'siang'),
                const SizedBox(width: 8),
                _buildMealTimeChip('Malam', 'malam'),
                const SizedBox(width: 8),
                _buildMealTimeChip('Snack', 'snack'),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Nama Makanan / Menu', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Contoh: Nasi Goreng Spesial'),
            ),
            const SizedBox(height: 16),

            const Text('Porsi', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _portionController,
              decoration: const InputDecoration(hintText: '1 porsi · 300g'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kalori (kkal)*', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '550'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Protein (g)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '30'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Makanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTimeChip(String label, String value) {
    final bool isSelected = _waktuMakan == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _waktuMakan = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.darkCharcoal : AppColors.divider,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.darkCharcoal,
            ),
          ),
        ),
      ),
    );
  }
}
