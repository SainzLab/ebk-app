import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/toast_notification.dart';

class _StudentRankItem {
  final String rank;
  final String name;
  final String subtitle;
  final String caseCountText;
  final Color rankBgColor;
  final Color rankBorderColor;
  final Color rankTextColor;
  final Color pillBgColor;
  final Color pillTextColor;

  const _StudentRankItem({
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.caseCountText,
    required this.rankBgColor,
    required this.rankBorderColor,
    required this.rankTextColor,
    required this.pillBgColor,
    required this.pillTextColor,
  });
}

/// Halaman Laporan Detail Analitik (`12 • Detail Analitik (SRS-F-012)`)
/// berdasarkan `12-detail-analitik-srs-f-012.png` dan `ebk_design.json`.
class DetailAnalitikScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;

  const DetailAnalitikScreen({
    super.key,
    this.onBack,
    this.isEmbedded = false,
  });

  @override
  State<DetailAnalitikScreen> createState() => _DetailAnalitikScreenState();
}

class _DetailAnalitikScreenState extends State<DetailAnalitikScreen> {
  int _selectedTabIndex = 0;

  static const List<_StudentRankItem> _topStudents = [
    _StudentRankItem(
      rank: '#1',
      name: 'Bagas Pratama',
      subtitle: 'Kelas VIII-B • Terlambat & Membolos',
      caseCountText: '5 Kasus',
      rankBgColor: AppColors.errorSurface,
      rankBorderColor: AppColors.errorBadgeBg,
      rankTextColor: AppColors.errorPrimary,
      pillBgColor: AppColors.errorSurface,
      pillTextColor: AppColors.errorPrimary,
    ),
    _StudentRankItem(
      rank: '#2',
      name: 'Dimas Anggara',
      subtitle: 'Kelas IX-A • Atribut & Ketertiban',
      caseCountText: '4 Kasus',
      rankBgColor: AppColors.warningSurface,
      rankBorderColor: AppColors.warningBorder,
      rankTextColor: AppColors.warningIcon,
      pillBgColor: AppColors.warningSurface,
      pillTextColor: AppColors.warningIcon,
    ),
    _StudentRankItem(
      rank: '#3',
      name: 'Fajar Nugraha',
      subtitle: 'Kelas VIII-A • Keterlambatan Masuk',
      caseCountText: '3 Kasus',
      rankBgColor: AppColors.warningSurface,
      rankBorderColor: AppColors.warningBorder,
      rankTextColor: AppColors.warningIcon,
      pillBgColor: AppColors.warningSurface,
      pillTextColor: AppColors.warningIcon,
    ),
    _StudentRankItem(
      rank: '#4',
      name: 'Raka Aditya Putra',
      subtitle: 'Kelas VIII-C • Kelengkapan Atribut',
      caseCountText: '2 Kasus',
      rankBgColor: AppColors.dividerSubtle,
      rankBorderColor: AppColors.borderNeutral,
      rankTextColor: AppColors.textSecondary,
      pillBgColor: AppColors.primaryTint,
      pillTextColor: AppColors.primaryNavy,
    ),
    _StudentRankItem(
      rank: '#5',
      name: 'Nabila Putri Rahayu',
      subtitle: 'Kelas VII-A • Keterlambatan Masuk',
      caseCountText: '2 Kasus',
      rankBgColor: AppColors.dividerSubtle,
      rankBorderColor: AppColors.borderNeutral,
      rankTextColor: AppColors.textSecondary,
      pillBgColor: AppColors.primaryTint,
      pillTextColor: AppColors.primaryNavy,
    ),
  ];

  void _handleDownloadPdf() {
    ToastNotification.show(
      context,
      message: 'Berhasil: Laporan PDF periode November 2026 telah diunduh.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Laporan Detail (height: 44.0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: AppColors.borderNeutral,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.shadowBase.withValues(alpha: 0.031),
                              offset: const Offset(0, 3),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'Laporan Detail',
                          style: AppTextStyles.topBarTitle,
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          'Periode November 2026',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11.0,
                            height: 14.0 / 11.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    // Filter Periode Icon Button (40x40, r=12, fill=#EBF2FF, stroke=#BFDBFE)
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.borderBlueAccent,
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13.0),
              // Segmented Control Tab (height: 44.0, r=14, pad=4, gap=4)
              Container(
                width: double.infinity,
                height: 44.0,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBase.withValues(alpha: 0.024),
                      offset: const Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _AnalitikSegmentedTab(
                        label: 'Berdasarkan Kelas',
                        isActive: _selectedTabIndex == 0,
                        onTap: () => setState(() {
                          _selectedTabIndex = 0;
                        }),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: _AnalitikSegmentedTab(
                        label: 'Berdasarkan Kasus',
                        isActive: _selectedTabIndex == 1,
                        onTap: () => setState(() {
                          _selectedTabIndex = 1;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13.0),
              // Card Ringkasan Berdasarkan Kelas (r=18, fill=#FFFFFF, stroke=#E2E8F0, pad=[12, 14], gap=10)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 14.0,
                ),
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
                      blurRadius: 12.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Distribusi Kelas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 16.0,
                              color: AppColors.primaryNavy,
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              'Sebaran Kasus per Tingkat Kelas',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12.0,
                                height: 16.0 / 12.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3.0,
                            horizontal: 9.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          child: const Text(
                            'Total 24 Kasus',
                            style: AppTextStyles.badgeBold10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    // Grid 3 Tingkat Kelas (gap: 8.0, height: 60.0)
                    Row(
                      children: const [
                        Expanded(
                          child: _GradeDistributionBox(
                            gradeLabel: 'Kelas VII',
                            percentageText: '21%',
                            caseCountText: '5 Kasus',
                            progressFraction: 0.54,
                            accentColor: AppColors.blueAccent,
                            bgColor: AppColors.inputSurfaceGray,
                            borderColor: AppColors.borderNeutral,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: _GradeDistributionBox(
                            gradeLabel: 'Kelas VIII',
                            percentageText: '46%',
                            caseCountText: '11 Kasus',
                            progressFraction: 1.0,
                            accentColor: AppColors.primaryNavy,
                            bgColor: AppColors.primaryTint,
                            borderColor: AppColors.borderBlueAccent,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: _GradeDistributionBox(
                            gradeLabel: 'Kelas IX',
                            percentageText: '33%',
                            caseCountText: '8 Kasus',
                            progressFraction: 0.77,
                            accentColor: AppColors.warningAccent,
                            bgColor: AppColors.inputSurfaceGray,
                            borderColor: AppColors.borderNeutral,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13.0),
              // Section Siswa dengan Kasus Terbanyak (gap: 9.0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Siswa dengan Kasus Terbanyak',
                    style: AppTextStyles.sectionHeader14,
                  ),
                  Text(
                    'Bulan Ini (Top 5)',
                    style: AppTextStyles.captionSemibold11,
                  ),
                ],
              ),
              const SizedBox(height: 9.0),
              // Tabel Ranking Siswa Kasus Terbanyak (r=18, fill=#FFFFFF, stroke=#E2E8F0)
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBase.withValues(alpha: 0.039),
                      offset: const Offset(0, 5),
                      blurRadius: 14.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Table Header Strip (height: 33.0, fill=#F8FAFC, pad=[9, 14])
                    Container(
                      width: double.infinity,
                      height: 33.0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 9.0,
                        horizontal: 14.0,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.inputSurfaceGray,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.borderNeutral,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 30.0,
                                child: Text(
                                  'NO',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 10.0,
                                    height: 14.0 / 10.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'NAMA SISWA & KELAS',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 10.0,
                                  height: 14.0 / 10.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'FREKUENSI',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10.0,
                              height: 14.0 / 10.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ranking Rows #1 - #5
                    ...List.generate(_topStudents.length, (index) {
                      final item = _topStudents[index];
                      final bool isLast = index == _topStudents.length - 1;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 11.0,
                          horizontal: 14.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: AppColors.dividerSubtle,
                                    width: 1.0,
                                  ),
                                ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28.0,
                                    height: 28.0,
                                    decoration: BoxDecoration(
                                      color: item.rankBgColor,
                                      borderRadius: BorderRadius.circular(9.0),
                                      border: Border.all(
                                        color: item.rankBorderColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.rank,
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 11.0,
                                        height: 15.0 / 11.0,
                                        fontWeight: FontWeight.w700,
                                        color: item.rankTextColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.name,
                                          style: AppTextStyles.cardTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          item.subtitle,
                                          style: AppTextStyles.subtitle11,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: item.pillBgColor,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: Text(
                                item.caseCountText,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11.0,
                                  height: 15.0 / 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: item.pillTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomActionBar(
        showHomeIndicator: !widget.isEmbedded,
        child: CustomButton.secondary(
          label: 'Unduh Laporan (PDF)',
          leadingIcon: Icons.file_download_outlined,
          height: 50.0,
          onPressed: _handleDownloadPdf,
        ),
      ),
    );
  }
}

class _AnalitikSegmentedTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnalitikSegmentedTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34.0,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.0,
            height: 16.0 / 12.0,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? AppColors.pureWhite : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _GradeDistributionBox extends StatelessWidget {
  final String gradeLabel;
  final String percentageText;
  final String caseCountText;
  final double progressFraction;
  final Color accentColor;
  final Color bgColor;
  final Color borderColor;

  const _GradeDistributionBox({
    required this.gradeLabel,
    required this.percentageText,
    required this.caseCountText,
    required this.progressFraction,
    required this.accentColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 10.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                gradeLabel,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 10.0,
                  height: 14.0 / 10.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                percentageText,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 10.0,
                  height: 14.0 / 10.0,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          Text(
            caseCountText,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.0,
              height: 17.0 / 13.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            width: double.infinity,
            height: 4.0,
            decoration: BoxDecoration(
              color: AppColors.borderNeutral,
              borderRadius: BorderRadius.circular(99.0),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progressFraction,
              child: Container(
                height: 4.0,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(99.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
