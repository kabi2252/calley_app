import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CalleyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterCallPressed;

  const CalleyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 0: Home
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                selected: currentIndex == 0,
              ),
              // 1: Calling Lists
              _buildNavItem(
                index: 1,
                icon: Icons.format_list_bulleted_rounded,
                selected: currentIndex == 1,
              ),
              // 2: Floating Center Call/Play Button
              GestureDetector(
                onTap: onCenterCallPressed ?? () => onTap(2),
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              // 3: Analytics / Logs
              _buildNavItem(
                index: 3,
                icon: Icons.pie_chart_rounded,
                selected: currentIndex == 3,
              ),
              // 4: Profile / Settings
              _buildNavItem(
                index: 4,
                icon: Icons.settings_rounded,
                selected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Icon(
          icon,
          size: 24,
          color: selected ? AppColors.primaryBlue : AppColors.textLight,
        ),
      ),
    );
  }
}
