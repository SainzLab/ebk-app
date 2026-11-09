import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import '../../repositories/analytics_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/animated_indexed_stack.dart';
import '../../widgets/profile_avatar.dart';
import '../features/data_siswa_screen.dart';
import '../features/detail_analitik_screen.dart';
import 'profil_view.dart';

/// Halaman Dashboard Kepala Sekolah (`05 • Dashboard Kepala Sekolah`)
/// berdasarkan `05-dashboard-kepala-sekolah.png` dan `ebk_design.json`.
class DashboardKepsekScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardKepsekScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<DashboardKepsekScreen> createState() => _DashboardKepsekScreenState();
}

class _DashboardKepsekScreenState extends State<DashboardKepsekScreen> {
  int _selectedTimeFilterIndex = 0;
  int _selectedNavIndex = 0;
  String _totalStudentsStr = '640';
  String _totalCasesStr = '24';
  String _completedSessionsStr = '19';

  @override
  void initState() {
    super.initState();
    _loadAnalyticsFromPocketBase();
  }

  Future<void> _loadAnalyticsFromPocketBase() async {
    try {
      final summary = await AnalyticsRepository.instance.getSummary();
      if (mounted && summary.totalStudents > 0) {
        setState(() {
          _totalStudentsStr = summary.totalStudents.toString();
          _totalCasesStr = summary.totalCases.toString();
          _completedSessionsStr = summary.completedCases.toString();
        });
      }
    } catch (_) {}
  }

  static const List<_MonthlyBarData> _monthlyBars = [
    _MonthlyBarData(month: 'Jun', count: 16, fillHeight: 36.0),
    _MonthlyBarData(month: 'Jul', count: 34, fillHeight: 76.0),
    _MonthlyBarData(month: 'Agu', count: 30, fillHeight: 67.0),
    _MonthlyBarData(month: 'Sep', count: 27, fillHeight: 60.0),
    _MonthlyBarData(month: 'Okt', count: 29, fillHeight: 65.0),
    _MonthlyBarData(month: 'Nov', count: 24, fillHeight: 54.0, isCurrent: true),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedNavIndex != 0) {
          setState(() {
            _selectedNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvasLightGray,
        body: AnimatedIndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildAnalitikContent(),
            DetailAnalitikScreen(
              isEmbedded: true,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
            DataSiswaScreen(
              role: ProfilRole.kepalaSekolah,
              isReadOnly: true,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
            ProfilView(
              role: ProfilRole.kepalaSekolah,
              onLogout: _handleLogout,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedNavIndex,
          items: CustomBottomNav.kepsekItems,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildAnalitikContent() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Kepala Sekolah (height: 46.0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileAvatar.currentUser(
                            size: 42.0,
                            fallbackIcon: Icons.person_outline_rounded,
                            onTap: () => setState(() => _selectedNavIndex = 3),
                          ),
                          const SizedBox(width: 10.0),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Analitik • SMPN 1 Pabuaran',
                                  style: AppTextStyles.captionSemibold11,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1.0),
                                Text(
                                  'Halo, Kepala Sekolah',
                                  style: AppTextStyles.greetingActor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              // Filter Rentang Waktu (height: 42.0, r=14, pad=4, gap=4)
              Container(
                width: double.infinity,
                height: 42.0,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentedTimeTab(
                        label: 'Bulan Ini',
                        isActive: _selectedTimeFilterIndex == 0,
                        onTap: () => setState(() {
                          _selectedTimeFilterIndex = 0;
                        }),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: _SegmentedTimeTab(
                        label: 'Semester Ini',
                        isActive: _selectedTimeFilterIndex == 1,
                        onTap: () => setState(() {
                          _selectedTimeFilterIndex = 1;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              // Tiga Card Statistik Utama (SRS-F-012)
              // Card 1 - Total Siswa Tercatat (height: 86, r=20, fill=#1B3B7B, pad=[16, 18])
              Container(
                width: double.infinity,
                height: 86.0,
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 18.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.18),
                      offset: const Offset(0, 6),
                      blurRadius: 18.0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Siswa Tercatat',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.0,
                            height: 16.0 / 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.borderBlueTint,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _totalStudentsStr,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 28.0,
                                height: 34.0 / 28.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pureWhite,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Siswa Aktif (Kelas VII–IX)',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11.0,
                                height: 15.0 / 11.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blueLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 46.0,
                      height: 46.0,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: AppColors.pureWhite.withValues(alpha: 0.18),
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.people_outline_rounded,
                        size: 22.0,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              // Statistik Row 2 & 3 (height: 118.0, gap: 10.0)
              Row(
                children: [
                  Expanded(
                    child: _ExecStatCard(
                      icon: Icons.description_outlined,
                      iconBgColor: AppColors.warningBg,
                      iconColor: AppColors.warningText,
                      badgeText: '-17% bln ini',
                      badgeBgColor: AppColors.successBg,
                      badgeTextColor: AppColors.successText,
                      value: _totalCasesStr,
                      label: 'Total Pelanggaran/Kasus',
                      onTap: () => _onNavTap(1),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _ExecStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconBgColor: AppColors.successBg,
                      iconColor: AppColors.successText,
                      badgeText: '79% Tuntas',
                      badgeBgColor: AppColors.primaryTint,
                      badgeTextColor: AppColors.primaryNavy,
                      value: _completedSessionsStr,
                      label: 'Sesi Konseling Selesai',
                      onTap: () => _onNavTap(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              // Card Chart Tren Kasus Pelanggaran per Bulan (r=22, pad=16, gap=12)
              GestureDetector(
                onTap: () => _onNavTap(1),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(
                      color: AppColors.borderNeutral,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBase.withValues(alpha: 0.039),
                        offset: const Offset(0, 6),
                        blurRadius: 18.0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chart Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tren Kasus Pelanggaran per Bulan',
                                  style: AppTextStyles.cardTitle,
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Periode Jun – Nov 2026',
                                  style: AppTextStyles.subtitle11,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 9.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.canvasLightGray,
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 7.0,
                                  height: 7.0,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryNavy,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                const Text(
                                  'Kasus',
                                  style: AppTextStyles.badgeSemibold10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      // Placeholder Bar Chart Area (height: 148, r=16, fill=#F8FAFC, stroke=#EEF2F6)
                      Container(
                        width: double.infinity,
                        height: 148.0,
                        padding: const EdgeInsets.fromLTRB(
                          12.0,
                          14.0,
                          12.0,
                          12.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputSurfaceGray,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppColors.borderSoft,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Y Axis
                            SizedBox(
                              width: 18.0,
                              height: 118.0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 14.0,
                                  bottom: 18.0,
                                  right: 2.0,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: const [
                                    Text(
                                      '40',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 10.0,
                                        height: 12.0 / 10.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPlaceholder,
                                      ),
                                    ),
                                    Text(
                                      '20',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 10.0,
                                        height: 12.0 / 10.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPlaceholder,
                                      ),
                                    ),
                                    Text(
                                      '0',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 10.0,
                                        height: 12.0 / 10.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPlaceholder,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            // Monthly Bars
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: _monthlyBars.map((bar) {
                                  return Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${bar.count}',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            fontSize: 10.0,
                                            height: 13.0 / 10.0,
                                            fontWeight: bar.isCurrent
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: bar.isCurrent
                                                ? AppColors.primaryNavy
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Container(
                                          width: 24.0,
                                          height: 84.0,
                                          decoration: BoxDecoration(
                                            color: AppColors.borderNeutral
                                                .withValues(alpha: 0.40),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: 24.0,
                                            height: bar.fillHeight,
                                            decoration: BoxDecoration(
                                              color: bar.isCurrent
                                                  ? AppColors.primaryNavy
                                                  : AppColors.blueLight,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(7.0),
                                                topRight: Radius.circular(7.0),
                                                bottomLeft:
                                                    Radius.circular(5.0),
                                                bottomRight:
                                                    Radius.circular(5.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          bar.month,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            fontSize: 10.0,
                                            height: 13.0 / 10.0,
                                            fontWeight: bar.isCurrent
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: bar.isCurrent
                                                ? AppColors.primaryNavy
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Ringkasan Tren Analitik (height: 32, r=12, fill=#EBF2FF, pad=[8, 12], gap=8)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down_rounded,
                              size: 16.0,
                              color: AppColors.primaryNavy,
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Kasus pelanggaran turun 17% di bulan November.',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11.0,
                                  height: 15.0 / 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _SegmentedTimeTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentedTimeTab({
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
        height: 32.0,
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

class _ExecStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _ExecStatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 118.0,
        padding: const EdgeInsets.symmetric(
          vertical: 13.0,
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
              blurRadius: 14.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 18.0,
                    color: iconColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3.0,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 10.0,
                      height: 13.0 / 10.0,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 22.0,
                    height: 28.0 / 22.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11.0,
                    height: 15.0 / 11.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarData {
  final String month;
  final int count;
  final double fillHeight;
  final bool isCurrent;

  const _MonthlyBarData({
    required this.month,
    required this.count,
    required this.fillHeight,
    this.isCurrent = false,
  });
}
