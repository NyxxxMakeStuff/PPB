import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/add_workout_sheet.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  void _openAddWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddWorkoutSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final workouts = state.filteredWorkouts.where((w) {
      if (_searchQuery.isEmpty) return true;
      return w.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Group workouts by date
    final Map<String, List<WorkoutItem>> groupedWorkouts = {};
    for (var item in workouts) {
      groupedWorkouts.putIfAbsent(item.dateGroup, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: RIWAYAT + Search Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RIWAYAT',
                        style: AppTheme.uppercaseSubHeader(),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: AppColors.darkCharcoal,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) _searchQuery = '';
                          });
                        },
                      ),
                    ],
                  ),

                  // Search bar field when active
                  if (_isSearching) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari latihan...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: AppColors.cardBg,
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                  // Title
                  Text(
                    'Latihan',
                    style: AppTheme.serifTitle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  // Summary text
                  Row(
                    children: const [
                      Text(
                        'Minggu ini',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('·', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        '5 sesi · 3 j 12 mnt',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Filter Chips Horizontal List
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua', WorkoutCategory.semua, state),
                        const SizedBox(width: 8),
                        _buildFilterChip('Beban', WorkoutCategory.beban, state),
                        const SizedBox(width: 8),
                        _buildFilterChip('Kardio', WorkoutCategory.kardio, state),
                        const SizedBox(width: 8),
                        _buildFilterChip('Core', WorkoutCategory.core, state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grouped Workouts List
                  if (groupedWorkouts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Tidak ada catatan latihan',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        ),
                      ),
                    )
                  else
                    ...groupedWorkouts.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Section Header
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                            child: Text(
                              entry.key,
                              style: AppTheme.uppercaseSubHeader(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                          // List items under date
                          ...entry.value.map((item) => _buildWorkoutRow(item)),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),

                  const SizedBox(height: 16),
                  // Bottom action link: "Lihat riwayat sebelumnya"
                  const Center(
                    child: Text(
                      'Lihat riwayat sebelumnya',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 90), // Spacing for FAB
                ],
              ),
            ),

            // Floating Action Button (+ Catat)
            Positioned(
              bottom: 24,
              right: 20,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddWorkoutSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    'Catat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, WorkoutCategory category, AppState state) {
    final bool isSelected = state.selectedWorkoutFilter == category;
    return GestureDetector(
      onTap: () => state.setWorkoutFilter(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.darkCharcoal : const Color(0xFFDED8C9),
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
    );
  }

  Widget _buildWorkoutRow(WorkoutItem workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          SizedBox(
            width: 44,
            child: Text(
              workout.time,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Category indicator line
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
}
