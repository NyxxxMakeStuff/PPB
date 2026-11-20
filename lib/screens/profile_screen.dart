import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditProfileSheet(),
    );
  }

  void _triggerBackup(BuildContext context, AppState state) {
    state.triggerBackupNow();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cadangan cloud berhasil diperbarui (${state.userProfile.lastBackup})!'),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar Akun', style: AppTheme.serifTitle(fontSize: 20)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun FitJournal?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.logout();
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final user = state.userProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Subtitle & Title
              Text(
                'AKUN',
                style: AppTheme.uppercaseSubHeader(),
              ),
              const SizedBox(height: 4),
              Text(
                'Profil',
                style: AppTheme.serifTitle(fontSize: 32),
              ),
              const SizedBox(height: 20),

              // User Info Card Header Row
              Row(
                children: [
                  // Circle Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2DAC7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name & Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email.isNotEmpty ? user.email : 'Belum terhubung',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // User Metrics Card (Berat, Tinggi, Target)
              GestureDetector(
                onTap: () => _openEditProfileSheet(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Berat',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.weightKg} kg',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.divider),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tinggi',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user.heightCm} cm',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.divider),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatNumber(user.targetKcal)} kkal',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Section: Cadangan data
              Text(
                'Cadangan data',
                style: AppTheme.serifTitle(fontSize: 22),
              ),
              const SizedBox(height: 12),

              // Cloud backup card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Column(
                  children: [
                    // Top row: Icon, title, subtitle, switch
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_outlined, size: 28, color: AppColors.darkCharcoal),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cadangan cloud',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Terakhir: ${user.lastBackup}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: user.cloudBackupEnabled,
                            activeThumbColor: const Color(0xFF2E6B4A),
                            onChanged: (val) {
                              state.toggleCloudBackup(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: AppColors.divider),
                    // Bottom row: "Cadangkan sekarang"
                    InkWell(
                      onTap: () => _triggerBackup(context, state),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cadangkan sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentOrange,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.accentOrange, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section: Pengaturan
              Text(
                'Pengaturan',
                style: AppTheme.serifTitle(fontSize: 22),
              ),
              const SizedBox(height: 8),

              // Settings list rows
              _buildSettingRow(
                context,
                title: 'Target harian',
                value: '${_formatNumber(user.targetKcal)} kkal · ${user.targetProteinG} g',
                onTap: () => _openEditProfileSheet(context),
              ),
              _buildSettingRow(
                context,
                title: 'Satuan',
                value: user.unitSystem,
                onTap: () {
                  state.updateUserSettings(unitSystem: user.unitSystem == 'Metrik' ? 'Imperial' : 'Metrik');
                },
              ),
              _buildSettingRow(
                context,
                title: 'Pengingat latihan',
                value: user.workoutReminder,
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 6, minute: 30),
                  );
                  if (picked != null) {
                    final formattedTime = '${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')}';
                    state.updateUserSettings(workoutReminder: formattedTime);
                  }
                },
              ),
              _buildSettingRow(
                context,
                title: 'Ekspor data',
                value: user.exportFormat,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File CSV berhasil diekspor ke folder Unduhan!'),
                      backgroundColor: AppColors.darkCharcoal,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Account action: Keluar
              GestureDetector(
                onTap: () => _showLogoutConfirmation(context, state),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Keluar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(BuildContext context, {required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.8)),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkCharcoal,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
