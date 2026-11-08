import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'profile_avatar.dart';

/// Komponen Reusable Kartu Siswa (`06 • Data Siswa (SRS-F-003)`)
/// dengan ukuran, padding, border, dan tipografi persis dari `ebk_design.json`.
class StudentCard extends StatelessWidget {
  final String name;
  final String nisn;
  final String className;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showAvatar;
  final bool showChevron;

  const StudentCard({
    super.key,
    required this.name,
    required this.nisn,
    required this.className,
    this.onTap,
    this.onLongPress,
    this.showAvatar = true,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: showAvatar ? 70.0 : 57.0,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(showAvatar ? 18.0 : 16.0),
        border: Border.all(
          color: AppColors.borderNeutral,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.031),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(showAvatar ? 18.0 : 16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 14.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showAvatar) ...[
                  const ProfileAvatar(
                    size: 44.0,
                    fallbackIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(width: 12.0),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        nisn.startsWith('NISN:') ? nisn : 'NISN: $nisn',
                        style: AppTextStyles.subtitle11,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        className,
                        style: AppTextStyles.badgeSemibold10,
                      ),
                    ),
                    if (showChevron) ...[
                      const SizedBox(width: 6.0),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16.0,
                        color: AppColors.textPlaceholder,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
