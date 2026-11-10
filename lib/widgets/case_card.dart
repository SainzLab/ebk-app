import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum CaseStatus {
  inProgress,
  completed,
}

/// Komponen Reusable Kartu Riwayat Kasus Anak (`04 • Dashboard Orang Tua`)
/// sesuai spesifikasi `ebk_design.json` dan selaras dengan `_CaseItemCard` pada Kelola Kasus.
class CaseCard extends StatelessWidget {
  final String? id;
  final String? category;
  final String? studentName;
  final String? studentClass;
  final String title;
  final String description;
  final String dateTimeText;
  final String? location;
  final String? handling;
  final int? violationPoints;
  final CaseStatus status;
  final VoidCallback? onTap;

  const CaseCard({
    super.key,
    this.id,
    this.category,
    this.studentName,
    this.studentClass,
    required this.title,
    required this.description,
    required this.dateTimeText,
    this.location,
    this.handling,
    this.violationPoints,
    required this.status,
    this.onTap,
  });

  /// Factory constructor praktis langsung dari [CaseRecordModel].
  factory CaseCard.fromModel(
    CaseRecordModel model, {
    VoidCallback? onTap,
    bool showStudentInfo = true,
  }) {
    return CaseCard(
      id: model.id,
      category: model.caseCategory,
      studentName: showStudentInfo ? model.studentName : null,
      studentClass: showStudentInfo ? model.studentClass : null,
      title: model.caseTitle,
      description: model.chronology,
      dateTimeText: model.incidentTime,
      location: model.incidentLocation,
      handling: model.handling,
      violationPoints: model.violationPoints,
      status: model.isCompleted ? CaseStatus.completed : CaseStatus.inProgress,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == CaseStatus.completed;

    final Color badgeBgColor =
        isCompleted ? AppColors.successBg : AppColors.warningBg;
    final Color badgeTextColor =
        isCompleted ? AppColors.successText : AppColors.warningText;
    final String badgeLabel = isCompleted ? 'Selesai' : 'Dalam Proses';

    final bool hasTopPills = (id != null && id!.isNotEmpty) ||
        (category != null && category!.isNotEmpty);
    final bool hasStudent = studentName != null && studentName!.isNotEmpty;
    final bool hasLocation = location != null && location!.isNotEmpty;
    final bool hasHandling = handling != null && handling!.isNotEmpty;
    final bool hasPoints = violationPoints != null && violationPoints! > 0;

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
            color: AppColors.shadowBase.withValues(alpha: 0.035),
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
              vertical: 14.0,
              horizontal: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header Baris (ID, Kategori, & Badge Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasTopPills)
                      Expanded(
                        child: Row(
                          children: [
                            if (id != null && id!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3.0,
                                  horizontal: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  id!,
                                  style: AppTextStyles.badgeBold10,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                            ],
                            if (category != null && category!.isNotEmpty)
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3.0,
                                    horizontal: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputSurfaceGray,
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      color: AppColors.borderNeutral,
                                    ),
                                  ),
                                  child: Text(
                                    category!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.subtitle11.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
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
                        vertical: 3.0,
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

                // 2. Judul Kasus (bila ID/kategori ditampilkan di atas)
                if (hasTopPills) ...[
                  const SizedBox(height: 10.0),
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 14.0,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],

                // 3. Info Siswa (Nama & Kelas) bila tersedia
                if (hasStudent) ...[
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14.0,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          '$studentName${studentClass != null && studentClass!.isNotEmpty ? ' • $studentClass' : ''}',
                          style: AppTextStyles.subtitle11.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // 4. Deskripsi / Kronologi
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall11,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8.0),

                // 5. Waktu Kejadian
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

                // 6. Tempat Kejadian (opsional)
                if (hasLocation) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14.0,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          location!,
                          style: AppTextStyles.paragraph12.copyWith(
                            fontSize: 11.0,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // 7. Kotak Penanganan Guru BK (bila ada)
                if (hasHandling) ...[
                  const SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputSurfaceGray,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 14.0,
                          color: AppColors.primaryNavy,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Penanganan: $handling',
                            style: AppTextStyles.paragraph12.copyWith(
                              fontSize: 11.0,
                              height: 15.0 / 11.0,
                              color: AppColors.textBody,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 8. Footer Baris (Poin & CTA Detail)
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasPoints)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(color: AppColors.errorBg),
                        ),
                        child: Text(
                          '+$violationPoints Poin',
                          style: AppTextStyles.badgeBold10.copyWith(
                            color: AppColors.errorPrimary,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: AppTextStyles.captionSemibold11.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16.0,
                          color: AppColors.primaryNavy,
                        ),
                      ],
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
