import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetKcalController;
  late TextEditingController _targetProteinController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _targetKcalController = TextEditingController();
    _targetProteinController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AppStateProvider.of(context).userProfile;
    _weightController.text = user.weightKg.toString();
    _heightController.text = user.heightCm.toString();
    _targetKcalController.text = user.targetKcal.toString();
    _targetProteinController.text = user.targetProteinG.toString();
  }

  void _saveProfile() {
    final state = AppStateProvider.of(context);
    state.updateUserTargets(
      weightKg: int.tryParse(_weightController.text) ?? state.userProfile.weightKg,
      heightCm: int.tryParse(_heightController.text) ?? state.userProfile.heightCm,
      targetKcal: int.tryParse(_targetKcalController.text) ?? state.userProfile.targetKcal,
      targetProteinG: int.tryParse(_targetProteinController.text) ?? state.userProfile.targetProteinG,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Target profil berhasil diperbarui!'),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _targetKcalController.dispose();
    _targetProteinController.dispose();
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
              'Edit Target & Data Tubuh',
              style: AppTheme.serifTitle(fontSize: 22),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Berat (kg)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '68'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tinggi (cm)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '172'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Kalori (kkal)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _targetKcalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '2600'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Protein (g)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _targetProteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '130'),
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
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkCharcoal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
