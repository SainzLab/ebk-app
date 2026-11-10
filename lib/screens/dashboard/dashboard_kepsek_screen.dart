import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import '../../core/pb_client.dart';
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
/// Menggunakan filter Range Tanggal dan Tahun sesuai kebutuhan pemantauan pimpinan sekolah.
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
  KepsekFilterMode _filterMode = KepsekFilterMode.dateRange;
  DateTime _startDate = DateTime(2026, 11, 1);
  DateTime _endDate = DateTime(2026, 11, 10);
  int _selectedYear = 2026;

  int _selectedNavIndex = 0;
  bool _isLoading = false;
  KepsekAnalyticsData? _analyticsData;

  static const List<MonthlyCaseTrend> _defaultMonthlyBars = [
    MonthlyCaseTrend(month: 'Jun', count: 0, fillHeight: 6.0),
    MonthlyCaseTrend(month: 'Jul', count: 0, fillHeight: 6.0),
    MonthlyCaseTrend(month: 'Agu', count: 0, fillHeight: 6.0),
    MonthlyCaseTrend(month: 'Sep', count: 0, fillHeight: 6.0),
    MonthlyCaseTrend(month: 'Okt', count: 0, fillHeight: 6.0),
    MonthlyCaseTrend(month: 'Nov', count: 0, fillHeight: 6.0, isCurrent: true),
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsFromPocketBase();
  }

  Future<void> _loadAnalyticsFromPocketBase() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await AnalyticsRepository.instance.getKepsekAnalytics(
        filterMode: _filterMode,
        startDate: _startDate,
        endDate: _endDate,
        selectedYear: _selectedYear,
      );
      if (mounted) {
        setState(() {
          _analyticsData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih Rentang Tanggal Analitik',
      cancelText: 'Batal',
      confirmText: 'Terapkan',
      saveText: 'Terapkan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: AppColors.pureWhite,
              surface: AppColors.pureWhite,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.pureWhite,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                textStyle: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedYear = picked.start.year;
      });
      _loadAnalyticsFromPocketBase();
    }
  }

  Future<void> _pickYear() async {
    final years = [2024, 2025, 2026, 2027, 2028];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Tahun Analitik',
                      style: AppTextStyles.cardTitle,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20.0,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                ...years.map((year) {
                  final isSelected = year == _selectedYear;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.event_note_rounded,
                      color: isSelected
                          ? AppColors.primaryNavy
                          : AppColors.textMuted,
                    ),
                    title: Text(
                      'Tahun $year',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.0,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryNavy,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (_selectedYear != year) {
                        setState(() {
                          _selectedYear = year;
                          _startDate = DateTime(year, 1, 1);
                          _endDate = DateTime(year, 12, 31);
                        });
                        _loadAnalyticsFromPocketBase();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

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
    final data = _analyticsData;
    final totalStudentsStr = data != null ? data.totalStudents.toString() : '-';
    final totalCasesStr = data?.totalCases.toString() ?? '0';
    final completedSessionsStr = data?.completedCases.toString() ?? '0';

    // Badge total kasus
    final caseBadgeText = data?.caseBadgeText ??
        (_filterMode == KepsekFilterMode.dateRange ? '0 Kasus' : '0% thn ini');
    Color caseBadgeBg = AppColors.successBg;
    Color caseBadgeTextColor = AppColors.successText;
    if (data != null) {
      if (data.isCaseDecreased) {
        caseBadgeBg = AppColors.successBg;
        caseBadgeTextColor = AppColors.successText;
      } else if (data.caseChangePercentage > 0) {
        caseBadgeBg = AppColors.errorSurface;
        caseBadgeTextColor = AppColors.errorPrimary;
      } else {
        caseBadgeBg = AppColors.canvasLightGray;
        caseBadgeTextColor = AppColors.textSecondary;
      }
    }

    // Badge sesi tuntas
    final completionBadgeText = data?.completionBadgeText ?? '100% Tuntas';

    // Chart bars & subtitle
    final monthlyBars = (data != null && data.monthlyBars.isNotEmpty)
        ? data.monthlyBars
        : _defaultMonthlyBars;
    final chartSubtitle =
        data?.trendPeriodSubtitle ?? 'Periode Jun – Nov $_selectedYear';

    // Y Axis labels calculation
    int maxBarCount = 0;
    for (final b in monthlyBars) {
      if (b.count > maxBarCount) maxBarCount = b.count;
    }
    final int topY = maxBarCount > 40
        ? (((maxBarCount + 9) ~/ 10) * 10)
        : (maxBarCount > 20 ? 40 : 20);
    final int midY = topY ~/ 2;

    // Trend summary row
    final isDecreased = data?.isCaseDecreased ?? true;
    final isIncreased = (data?.caseChangePercentage ?? 0) > 0;
    final IconData trendIcon = isDecreased
        ? Icons.trending_down_rounded
        : (isIncreased
            ? Icons.trending_up_rounded
            : Icons.trending_flat_rounded);
    final Color trendColor = isDecreased
        ? AppColors.primaryNavy
        : (isIncreased ? AppColors.errorPrimary : AppColors.primaryNavy);
    final Color trendBg = isDecreased
        ? AppColors.primaryTint
        : (isIncreased ? AppColors.errorSurface : AppColors.primaryTint);
    final String trendText = data?.trendSummaryText ??
        'Data analitik siap dipantau untuk periode terpilih.';

    // Label tampilan filter aktif
    final String activeFilterValue = _filterMode == KepsekFilterMode.dateRange
        ? (_startDate.isAtSameMomentAs(_endDate)
            ? PbClient.formatDateFull(_startDate)
            : '${PbClient.formatDateShort(_startDate)} – ${PbClient.formatDateShort(_endDate)}')
        : 'Tahun $_selectedYear';

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadAnalyticsFromPocketBase,
        color: AppColors.primaryNavy,
        backgroundColor: AppColors.pureWhite,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    if (_isLoading)
                      const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryNavy,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),

              // Filter Bar Range Tanggal dan Tahun
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
                        label: 'Tanggal',
                        icon: Icons.date_range_rounded,
                        isActive: _filterMode == KepsekFilterMode.dateRange,
                        onTap: () {
                          if (_filterMode != KepsekFilterMode.dateRange) {
                            setState(() {
                              _filterMode = KepsekFilterMode.dateRange;
                            });
                            _loadAnalyticsFromPocketBase();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: _SegmentedTimeTab(
                        label: 'Tahun',
                        icon: Icons.calendar_month_rounded,
                        isActive: _filterMode == KepsekFilterMode.year,
                        onTap: () {
                          if (_filterMode != KepsekFilterMode.year) {
                            setState(() {
                              _filterMode = KepsekFilterMode.year;
                            });
                            _loadAnalyticsFromPocketBase();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),

              // Kartu Selector Interaktif (Pilih Range Tanggal atau Tahun)
              GestureDetector(
                onTap: _filterMode == KepsekFilterMode.dateRange
                    ? _pickDateRange
                    : _pickYear,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: AppColors.borderBlueAccent.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBase.withValues(alpha: 0.025),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _filterMode == KepsekFilterMode.dateRange
                                  ? Icons.date_range_rounded
                                  : Icons.calendar_month_rounded,
                              size: 18.0,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _filterMode == KepsekFilterMode.dateRange
                                    ? 'Filter Tanggal'
                                    : 'Filter Tahun',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 10.0,
                                  height: 13.0 / 10.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                activeFilterValue,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12.0,
                                  height: 16.0 / 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 9.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _filterMode == KepsekFilterMode.dateRange
                                  ? 'Ubah Range'
                                  : 'Ubah Tahun',
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11.0,
                                height: 14.0 / 11.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 3.0),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 15.0,
                              color: AppColors.primaryNavy,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14.0),

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
                              totalStudentsStr,
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
                      badgeText: caseBadgeText,
                      badgeBgColor: caseBadgeBg,
                      badgeTextColor: caseBadgeTextColor,
                      value: totalCasesStr,
                      label: _filterMode == KepsekFilterMode.dateRange
                          ? 'Kasus pada Rentang Ini'
                          : 'Total Kasus Tahun $_selectedYear',
                      onTap: () => _onNavTap(1),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _ExecStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconBgColor: AppColors.successBg,
                      iconColor: AppColors.successText,
                      badgeText: completionBadgeText,
                      badgeBgColor: AppColors.primaryTint,
                      badgeTextColor: AppColors.primaryNavy,
                      value: completedSessionsStr,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Tren Kasus Pelanggaran per Bulan',
                                  style: AppTextStyles.cardTitle,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  chartSubtitle,
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
                      // Bar Chart Area (height: 148, r=16, fill=#F8FAFC, stroke=#EEF2F6)
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
                              width: 22.0,
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
                                  children: [
                                    Text(
                                      '$topY',
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 10.0,
                                        height: 12.0 / 10.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPlaceholder,
                                      ),
                                    ),
                                    Text(
                                      '$midY',
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 10.0,
                                        height: 12.0 / 10.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPlaceholder,
                                      ),
                                    ),
                                    const Text(
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
                            const SizedBox(width: 8.0),
                            // Monthly Bars
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: monthlyBars.map((bar) {
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
                      // Ringkasan Tren Analitik
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: trendBg,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              trendIcon,
                              size: 16.0,
                              color: trendColor,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                trendText,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11.0,
                                  height: 15.0 / 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: trendColor,
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
      ),
    );
  }
}

class _SegmentedTimeTab extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentedTimeTab({
    required this.label,
    this.icon,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.0,
                color: isActive ? AppColors.pureWhite : AppColors.textMuted,
              ),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.0,
                height: 16.0 / 12.0,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? AppColors.pureWhite : AppColors.textMuted,
              ),
            ),
          ],
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
