import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  const HomeScreen({super.key, required this.onNavigateTab});

  String _formattedTodayDate() {
    final now = DateTime.now();
    final days = ['MINGGU', 'SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU'];
    final months = ['JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI', 'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'];
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final user = state.userProfile;
    final todayWorkouts = state.filteredWorkouts.where((w) {
      return w.dateGroup.contains('HARI INI') || w.dateGroup.contains('KAM');
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Date & Status pill)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formattedTodayDate(),
                    style: AppTheme.uppercaseSubHeader(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDFD9CA), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: state.isLoggedIn && !state.isGuestMode ? const Color(0xFF2E6B4A) : AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isLoggedIn && !state.isGuestMode ? 'Terhubung ke server' : 'Tersimpan lokal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Main Greeting Title
              Text(
                'Halo, ${user.name.split(' ').first}',
                style: AppTheme.serifTitle(fontSize: 32),
              ),
              const SizedBox(height: 20),

              // Today's Calorie Summary Card
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
                    const Text(
                      'Kalori hari ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatNumber(state.caloriesConsumed),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/ ${_formatNumber(user.targetKcal)} kkal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        double progress = user.targetKcal > 0
                            ? (state.caloriesConsumed / user.targetKcal).clamp(0.0, 1.0)
                            : 0.0;
                        return Stack(
                          children: [
                            Container(
                              height: 10,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFEADF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Container(
                              height: 10,
                              width: constraints.maxWidth * progress,
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Bottom 3 columns: Protein, Olahraga, Sisa
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Protein',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.proteinConsumed} / ${user.targetProteinG} g',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: AppColors.divider),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Olahraga',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${state.exerciseMinutes} mnt',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 32, color: AppColors.divider),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sisa',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatNumber(state.remainingCalories)} kkal',
                                  style: const TextStyle(
                                    fontSize: 16,
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
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section: Minggu ini & Kalori link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minggu ini',
                    style: AppTheme.serifTitle(fontSize: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Kalori',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 44,
                        height: 2,
                        color: AppColors.accentOrange,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weekly Bar Chart Container
              Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  children: [
                    // Target Line Indicator label
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Target ${_formatNumber(user.targetKcal)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Bar Chart Body with Dashed Line
                    Expanded(
                      child: Stack(
                        children: [
                          // Dashed Line at target height
                          Positioned(
                            top: 18,
                            left: 0,
                            right: 0,
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: DashedLinePainter(color: AppColors.accentOrange),
                            ),
                          ),
                          // Bars row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar('Sen', 0.65, isSelected: false),
                              _buildBar('Sel', 0.85, isSelected: false),
                              _buildBar('Rab', 0.78, isSelected: false),
                              _buildBar('Kam', 0.70, isSelected: true, valueLabel: _formatNumber(state.caloriesConsumed)),
                              _buildDashedBar('Jum'),
                              _buildDashedBar('Sab'),
                              _buildDashedBar('Min'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Latihan hari ini & Lihat semua
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latihan hari ini',
                    style: AppTheme.serifTitle(fontSize: 22),
                  ),
                  GestureDetector(
                    onTap: () => onNavigateTab(1), // Navigate to Workout Tab
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Workout items list
              if (todayWorkouts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada catatan latihan hari ini.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                )
              else
                ...todayWorkouts.map((workout) => _buildWorkoutRow(workout)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String day, double heightRatio, {required bool isSelected, String? valueLabel}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (valueLabel != null)
          Text(
            valueLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.accentOrange,
            ),
          )
        else
          const SizedBox(height: 15),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 95 * heightRatio,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentOrange : const Color(0xFFDFD7C4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.darkCharcoal : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedBar(String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 19),
        CustomPaint(
          size: const Size(32, 40),
          painter: DashedRectPainter(color: const Color(0xFFD4CDBC)),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutRow(WorkoutItem workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        children: [
          // Left side colored category line
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: workout.categoryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  workout.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Value right
          Text(
            workout.value,
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 4, dashSpace = 4, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 3, dashSpace = 3;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
