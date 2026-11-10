import 'package:flutter/material.dart';
import '../../core/pb_client.dart';
import '../../repositories/analytics_repository.dart';
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
/// Menampilkan laporan mendalam berdasarkan Rentang Tanggal dan Tahun.
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
  int _selectedTabIndex = 0; // 0: Berdasarkan Kelas, 1: Berdasarkan Kasus
  KepsekFilterMode _filterMode = KepsekFilterMode.dateRange;

  // Default rentang tanggal: awal bulan sampai tanggal berjalan
  DateTime _startDate = DateTime(2026, 11, 1);
  DateTime _endDate = DateTime(2026, 11, 10);
  int _selectedYear = 2026;

  bool _isLoading = false;
  KepsekAnalyticsData? _analyticsData;
  String _periodSubtitle = 'Periode 01 Nov 2026 – 10 Nov 2026';

  List<_StudentRankItem> _topStudents = [];

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
          _periodSubtitle = 'Periode ${data.periodName}';

          _topStudents = List.generate(data.topStudents.length, (i) {
            final item = data.topStudents[i];
            final isFirst = i == 0;
            final isTopThree = i < 3;
            return _StudentRankItem(
              rank: '#${i + 1}',
              name: item.studentName,
              subtitle:
                  '${item.studentClass} • Total ${item.totalPoints} Poin',
              caseCountText: '${item.caseCount} Kasus',
              rankBgColor: isFirst
                  ? AppColors.errorSurface
                  : (isTopThree
                      ? AppColors.warningSurface
                      : AppColors.dividerSubtle),
              rankBorderColor: isFirst
                  ? AppColors.errorBadgeBg
                  : (isTopThree
                      ? AppColors.warningBorder
                      : AppColors.borderNeutral),
              rankTextColor: isFirst
                  ? AppColors.errorPrimary
                  : (isTopThree
                      ? AppColors.warningIcon
                      : AppColors.textSecondary),
              pillBgColor: isFirst
                  ? AppColors.errorSurface
                  : (isTopThree
                      ? AppColors.warningSurface
                      : AppColors.primaryTint),
              pillTextColor: isFirst
                  ? AppColors.errorPrimary
                  : (isTopThree
                      ? AppColors.warningIcon
                      : AppColors.primaryNavy),
            );
          });
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
        _filterMode = KepsekFilterMode.dateRange;
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
                  final isSelected =
                      _filterMode == KepsekFilterMode.year && year == _selectedYear;
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
                      setState(() {
                        _filterMode = KepsekFilterMode.year;
                        _selectedYear = year;
                        _startDate = DateTime(year, 1, 1);
                        _endDate = DateTime(year, 12, 31);
                      });
                      _loadAnalyticsFromPocketBase();
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

  void _showPeriodFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext ctx) {
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
                      'Pilih Filter Analitik',
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.date_range_outlined,
                    color: _filterMode == KepsekFilterMode.dateRange
                        ? AppColors.primaryNavy
                        : AppColors.textMuted,
                  ),
                  title: const Text(
                    'Filter Range Tanggal',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Aktif: ${_filterMode == KepsekFilterMode.dateRange ? _periodSubtitle : "${PbClient.formatDateShort(_startDate)} – ${PbClient.formatDateShort(_endDate)}"}',
                    style: AppTextStyles.subtitle11,
                  ),
                  trailing: _filterMode == KepsekFilterMode.dateRange
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryNavy,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickDateRange();
                  },
                ),
                const Divider(height: 1.0, color: AppColors.dividerSubtle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.calendar_month_outlined,
                    color: _filterMode == KepsekFilterMode.year
                        ? AppColors.primaryNavy
                        : AppColors.textMuted,
                  ),
                  title: const Text(
                    'Filter Berdasarkan Tahun',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Aktif: Tahun $_selectedYear',
                    style: AppTextStyles.subtitle11,
                  ),
                  trailing: _filterMode == KepsekFilterMode.year
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryNavy,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickYear();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleDownloadPdf() {
    ToastNotification.show(
      context,
      message: 'Berhasil: Laporan PDF $_periodSubtitle telah diunduh.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _analyticsData;
    final totalCases = data?.totalCases ?? 0;

    final String activeFilterValue = _filterMode == KepsekFilterMode.dateRange
        ? (_startDate.isAtSameMomentAs(_endDate)
            ? PbClient.formatDateFull(_startDate)
            : '${PbClient.formatDateShort(_startDate)} – ${PbClient.formatDateShort(_endDate)}')
        : 'Tahun $_selectedYear';

    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
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
                                color: AppColors.shadowBase
                                    .withValues(alpha: 0.031),
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
                        children: [
                          const Text(
                            'Laporan Detail',
                            style: AppTextStyles.topBarTitle,
                          ),
                          const SizedBox(height: 1.0),
                          Text(
                            _periodSubtitle,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11.0,
                              height: 14.0 / 11.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      // Filter Periode Icon Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading) ...[
                            const SizedBox(
                              width: 18.0,
                              height: 18.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryNavy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                          GestureDetector(
                            onTap: _showPeriodFilterDialog,
                            child: Container(
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),

                // Bar Filter Mode (Range Tanggal dan Tahun) — Sama seperti di Dashboard
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
                        child: _DetailFilterTab(
                          label: 'Range Tanggal',
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
                        child: _DetailFilterTab(
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
                                      ? 'Filter Range Tanggal'
                                      : 'Filter Tahun Terpilih',
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
                const SizedBox(height: 12.0),

                // Segmented Control Tab (Berdasarkan Kelas vs Berdasarkan Kasus)
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

                // Konten Tab: Berdasarkan Kelas vs Berdasarkan Kasus
                if (_selectedTabIndex == 0)
                  _buildByGradeCard(totalCases, data)
                else
                  _buildByCategoryCard(totalCases, data),

                const SizedBox(height: 13.0),
                // Section Siswa dengan Kasus Terbanyak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Siswa dengan Kasus Terbanyak',
                      style: AppTextStyles.sectionHeader14,
                    ),
                    Text(
                      _filterMode == KepsekFilterMode.dateRange
                          ? 'Rentang Ini (Top 5)'
                          : 'Tahun $_selectedYear (Top 5)',
                      style: AppTextStyles.captionSemibold11,
                    ),
                  ],
                ),
                const SizedBox(height: 9.0),

                // Tabel Ranking Siswa Kasus Terbanyak
                if (_topStudents.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: AppColors.borderNeutral,
                        width: 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.verified_outlined,
                          size: 32.0,
                          color: AppColors.primaryNavy,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Tidak Ada Kasus Pelanggaran',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.0),
                        Text(
                          'Belum ada catatan pelanggaran siswa pada periode yang dipilih.',
                          style: AppTextStyles.subtitle11,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
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
                        // Table Header Strip
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
                            children: const [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                              Text(
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
                                          borderRadius:
                                              BorderRadius.circular(9.0),
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

  Widget _buildByGradeCard(int totalCases, KepsekAnalyticsData? data) {
    GradeCaseSummary g7 = const GradeCaseSummary(
      gradeLevel: 'Kelas VII',
      totalCases: 0,
      completedCases: 0,
      percentage: 0.0,
      progressFraction: 0.0,
    );
    GradeCaseSummary g8 = const GradeCaseSummary(
      gradeLevel: 'Kelas VIII',
      totalCases: 0,
      completedCases: 0,
      percentage: 0.0,
      progressFraction: 0.0,
    );
    GradeCaseSummary g9 = const GradeCaseSummary(
      gradeLevel: 'Kelas IX',
      totalCases: 0,
      completedCases: 0,
      percentage: 0.0,
      progressFraction: 0.0,
    );

    if (data != null && data.gradeDistributions.length >= 3) {
      g7 = data.gradeDistributions[0];
      g8 = data.gradeDistributions[1];
      g9 = data.gradeDistributions[2];
    }

    final int totalCasesInGrades = g7.totalCases + g8.totalCases + g9.totalCases;

    return Container(
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
                child: Text(
                  'Total $totalCasesInGrades Kasus',
                  style: AppTextStyles.badgeBold10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Grid 3 Tingkat Kelas
          Row(
            children: [
              Expanded(
                child: _GradeDistributionBox(
                  gradeLabel: g7.gradeLevel,
                  percentageText: '${g7.percentage.round()}%',
                  caseCountText: '${g7.totalCases} Kasus',
                  progressFraction: g7.progressFraction,
                  accentColor: AppColors.blueAccent,
                  bgColor: AppColors.inputSurfaceGray,
                  borderColor: AppColors.borderNeutral,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _GradeDistributionBox(
                  gradeLabel: g8.gradeLevel,
                  percentageText: '${g8.percentage.round()}%',
                  caseCountText: '${g8.totalCases} Kasus',
                  progressFraction: g8.progressFraction,
                  accentColor: AppColors.primaryNavy,
                  bgColor: AppColors.primaryTint,
                  borderColor: AppColors.borderBlueAccent,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _GradeDistributionBox(
                  gradeLabel: g9.gradeLevel,
                  percentageText: '${g9.percentage.round()}%',
                  caseCountText: '${g9.totalCases} Kasus',
                  progressFraction: g9.progressFraction,
                  accentColor: AppColors.warningAccent,
                  bgColor: AppColors.inputSurfaceGray,
                  borderColor: AppColors.borderNeutral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildByCategoryCard(int totalCases, KepsekAnalyticsData? data) {
    List<CategoryCaseSummary> cats = data?.categoryDistributions ?? [];

    return Container(
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
          // Header Distribusi Kategori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.category_outlined,
                    size: 16.0,
                    color: AppColors.primaryNavy,
                  ),
                  SizedBox(width: 6.0),
                  Text(
                    'Sebaran Kasus per Kategori',
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
                child: Text(
                  'Total $totalCases Kasus',
                  style: AppTextStyles.badgeBold10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (cats.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: const Text(
                'Tidak ada kategori kasus tercatat pada periode ini.',
                style: AppTextStyles.subtitle11,
              ),
            )
          else
            ...cats.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat.categoryName,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${cat.caseCount} Kasus (${cat.percentage.round()}%)',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      width: double.infinity,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: AppColors.inputSurfaceGray,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: cat.progressFraction.clamp(0.05, 1.0),
                        child: Container(
                          height: 6.0,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DetailFilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _DetailFilterTab({
    required this.label,
    required this.icon,
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
            Icon(
              icon,
              size: 14.0,
              color: isActive ? AppColors.pureWhite : AppColors.textMuted,
            ),
            const SizedBox(width: 6.0),
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
              widthFactor: progressFraction.clamp(0.05, 1.0),
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
