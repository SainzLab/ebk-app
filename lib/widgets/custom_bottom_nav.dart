import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BottomNavItemData {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const BottomNavItemData({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

/// Komponen Navigasi Bawah Standar untuk seluruh Dashboard
/// (`03 • Dashboard Guru BK`, `04 • Dashboard Orang Tua`, `05 • Dashboard Kepala Sekolah`)
/// sesuai nilai padding, ukuran, dan warna pada `ebk_design.json`.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavItemData> items;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  });

  /// Preset Navigasi Bawah untuk Guru BK (Gambar 03)
  static const List<BottomNavItemData> guruItems = [
    BottomNavItemData(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    BottomNavItemData(
      label: 'Jadwal',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
    ),
    BottomNavItemData(
      label: 'Kasus',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
    ),
    BottomNavItemData(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  /// Preset Navigasi Bawah untuk Orang Tua Siswa (Gambar 04)
  static const List<BottomNavItemData> ortuItems = [
    BottomNavItemData(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    BottomNavItemData(
      label: 'Laporan',
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
    ),
    BottomNavItemData(
      label: 'Konsultasi',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    BottomNavItemData(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  /// Preset Navigasi Bawah untuk Kepala Sekolah (Gambar 05)
  static const List<BottomNavItemData> kepsekItems = [
    BottomNavItemData(
      label: 'Analitik',
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart_rounded,
    ),
    BottomNavItemData(
      label: 'Laporan',
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
    ),
    BottomNavItemData(
      label: 'Siswa',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
    ),
    BottomNavItemData(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 82.0,
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: const Border(
          top: BorderSide(
            color: AppColors.borderNeutral,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.039),
            offset: const Offset(0, -4),
            blurRadius: 16.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 46.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final bool isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap?.call(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: isSelected ? 52.0 : 44.0,
                          height: 28.0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryTint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            scale: isSelected ? 1.15 : 1.0,
                            child: Icon(
                              isSelected
                                  ? (item.activeIcon ?? item.icon)
                                  : item.icon,
                              size: 20.0,
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11.0,
                            height: 14.0 / 11.0,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryNavy
                                : AppColors.textMuted,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            width: 134.0,
            height: 5.0,
            decoration: BoxDecoration(
              color: AppColors.borderMuted,
              borderRadius: BorderRadius.circular(99.0),
            ),
          ),
        ],
      ),
    );
  }
}
