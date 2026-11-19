import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class AddWorkoutSheet extends StatefulWidget {
  const AddWorkoutSheet({super.key});

  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _setsController = TextEditingController(text: '3 set × 10');
  final TextEditingController _valueController = TextEditingController(text: '30 rep');
  WorkoutCategory _selectedCategory = WorkoutCategory.beban;
  int _durationMins = 15;

  void _saveWorkout() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final state = AppStateProvider.of(context);
    state.addWorkout(
      title: title,
      subtitle: _setsController.text.trim(),
      value: _valueController.text.trim(),
      category: _selectedCategory,
      durationMinutes: _durationMins,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Latihan "$title" berhasil dicatat!'),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _setsController.dispose();
    _valueController.dispose();
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
            // Handle bar
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
              'Catat Latihan Baru',
              style: AppTheme.serifTitle(fontSize: 22),
            ),
            const SizedBox(height: 20),

            // Nama Latihan
            const Text('Nama Latihan', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Contoh: Bench press, Running'),
            ),
            const SizedBox(height: 16),

            // Kategori
            const Text('Kategori', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCategoryOption('Beban', WorkoutCategory.beban),
                const SizedBox(width: 8),
                _buildCategoryOption('Kardio', WorkoutCategory.kardio),
                const SizedBox(width: 8),
                _buildCategoryOption('Core', WorkoutCategory.core),
              ],
            ),
            const SizedBox(height: 16),

            // Sets & Reps
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detail Set / Rincian', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _setsController,
                        decoration: const InputDecoration(hintText: '3 set × 10 repetisi'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Beban/Rep', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _valueController,
                        decoration: const InputDecoration(hintText: '300 kg / 30 rep'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Latihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String label, WorkoutCategory category) {
    final bool isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
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
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.darkCharcoal,
            ),
          ),
        ),
      ),
    );
  }
}
