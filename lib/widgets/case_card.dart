import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum CaseStatus {
  inProgress,
  completed,
}

/// Komponen Reusable Kartu Riwayat Kasus Anak (`04 • Dashboard Orang Tua`)
/// sesuai spesifikasi `ebk_design.json`.
class CaseCard extends StatelessWidget {
  final String title;
  final String description;
  final String dateTimeText;
  final CaseStatus status;
  final VoidCallback? onTap;

  const CaseCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateTimeText,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == CaseStatus.completed;

    final Color badgeBgColor =
        isCompleted ? AppColors.successBg : AppColors.warningBg;
    final Color badgeTextColor =
        isCompleted ? AppColors.successText : AppColors.warningText;
    final String badgeLabel = isCompleted ? 'Selesai' : 'Dalam Proses';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: AppColors.borderNeutral,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.031),
            offset: const Offset(0, 4),
            blurRadius: 14.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 13.0,
              horizontal: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul & Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      height: 22.0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 10.0,
                          height: 14.0 / 10.0,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Catatan Pendampingan
                Text(
                  description,
                  style: AppTextStyles.bodySmall11,
                ),
                const SizedBox(height: 8.0),
                // Waktu Kejadian Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14.0,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        dateTimeText,
                        style: AppTextStyles.captionSemibold11,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
