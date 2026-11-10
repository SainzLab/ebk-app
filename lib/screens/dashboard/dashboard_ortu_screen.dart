import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import '../../models/case_model.dart';
import '../../models/student_model.dart';
import '../../repositories/case_repository.dart';
import '../../repositories/student_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/case_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/animated_indexed_stack.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/toast_notification.dart';
import '../features/ajukan_konsultasi_screen.dart';
import '../features/detail_kasus_screen.dart';
import 'profil_view.dart';

enum CaseSortOption {
  latest('Terbaru (Waktu Kejadian)'),
  oldest('Terlama (Waktu Kejadian)'),
  highestPoints('Poin Tertinggi (Berat ke Ringan)');

  final String label;
  const CaseSortOption(this.label);
}

/// Shimmer Skeleton Card saat memuat data laporan kasus orang tua
class _OrtuSkeletonCaseCard extends StatefulWidget {
  const _OrtuSkeletonCaseCard();

  @override
  State<_OrtuSkeletonCaseCard> createState() => _OrtuSkeletonCaseCardState();
}

class _OrtuSkeletonCaseCardState extends State<_OrtuSkeletonCaseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = (_controller.value * 2) - 1;
        final gradient = LinearGradient(
          begin: Alignment(-1.0 + slide, 0.0),
          end: Alignment(1.0 + slide, 0.0),
          colors: const [
            AppColors.skeletonBase,
            AppColors.skeletonHighlight,
            AppColors.skeletonBase,
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: AppColors.borderNeutral),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBase.withValues(alpha: 0.025),
                offset: const Offset(0, 4),
                blurRadius: 12.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90.0,
                    height: 18.0,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  Container(
                    width: 72.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Container(
                width: 220.0,
                height: 16.0,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                width: 150.0,
                height: 12.0,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: 180.0,
                height: 12.0,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Halaman Dashboard Orang Tua (`04 • Dashboard Orang Tua`)
/// berdasarkan `04-dashboard-orang-tua.png` dan `ebk_design.json`.
class DashboardOrtuScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardOrtuScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
  int _selectedNavIndex = 0;

  List<CaseRecordModel> _cases = const [];
  CaseRecordModel? _selectedCase;
  List<StudentDataModel> _children = const [];
  String _selectedChildId = ''; // '' = semua anak
  bool _isLoadingCases = true;
  String? _loadError;

  // Search & Filter State untuk Tab Laporan Kasus
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedQuickFilter = 'Semua';
  String? _selectedCaseTypeFilter;
  String _selectedStatusFilter = 'Semua';
  CaseSortOption _selectedSortOption = CaseSortOption.latest;

  static const List<String> _quickFilterCategories = [
    'Semua',
    'Dalam Proses',
    'Selesai',
    'Membolos',
    'Kedisiplinan',
  ];

  static const List<String> _caseTypeOptions = [
    'Semua Jenis',
    'Membolos',
    'Tawuran',
    'Atribut Seragam',
    'Keterlambatan',
    'Merokok / Vape',
    'Perundungan',
    'Kedisiplinan',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrtuDataFromPocketBase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrtuDataFromPocketBase() async {
    if (mounted) {
      setState(() {
        _isLoadingCases = true;
        _loadError = null;
      });
    }
    try {
      final myChildren = await StudentRepository.instance.getMyChildren();
      final myCases = await CaseRepository.instance.getMyCases(myChildren);
      if (!mounted) return;
      setState(() {
        _children = myChildren;
        _cases = myCases;
        _isLoadingCases = false;
        if (_selectedChildId.isNotEmpty &&
            !myChildren.any((c) => c.id == _selectedChildId)) {
          _selectedChildId = '';
        }
        if (_selectedCase != null &&
            !myCases.any((c) => c.recordId == _selectedCase!.recordId)) {
          _selectedCase = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCases = false;
        _loadError =
            'Gagal memuat data kasus. Tarik ke bawah untuk mencoba lagi.';
      });
    }
  }

  /// Kasus yang tampil sesuai filter anak (untuk home tab)
  List<CaseRecordModel> get _visibleCases => _selectedChildId.isEmpty
      ? _cases
      : _cases.where((c) => c.studentId == _selectedChildId).toList();

  /// Kasus terfilter lengkap untuk Tab Laporan Kasus
  List<CaseRecordModel> get _filteredCases {
    final q = _searchQuery.trim().toLowerCase();
    final list = _cases.where((c) {
      // 1. Filter anak
      if (_selectedChildId.isNotEmpty && c.studentId != _selectedChildId) {
        return false;
      }

      // 2. Quick horizontal filter chip
      if (_selectedQuickFilter == 'Membolos') {
        if (!c.caseTitle.toLowerCase().contains('membolos')) return false;
      } else if (_selectedQuickFilter == 'Kedisiplinan') {
        if (!c.caseCategory.toLowerCase().contains('disiplin')) return false;
      } else if (_selectedQuickFilter == 'Dalam Proses') {
        if (c.isCompleted) return false;
      } else if (_selectedQuickFilter == 'Selesai') {
        if (!c.isCompleted) return false;
      }

      // 3. Modal sheet case type filter
      if (_selectedCaseTypeFilter != null) {
        final matchesTitle = c.caseTitle
            .toLowerCase()
            .contains(_selectedCaseTypeFilter!.toLowerCase());
        final matchesCat = c.caseCategory
            .toLowerCase()
            .contains(_selectedCaseTypeFilter!.toLowerCase());
        if (!matchesTitle && !matchesCat) return false;
      }

      // 4. Modal sheet status filter
      if (_selectedStatusFilter == 'Dalam Proses' && c.isCompleted) {
        return false;
      } else if (_selectedStatusFilter == 'Selesai' && !c.isCompleted) {
        return false;
      }

      // 5. Search query
      if (q.isNotEmpty) {
        final matches = c.caseTitle.toLowerCase().contains(q) ||
            c.chronology.toLowerCase().contains(q) ||
            c.studentName.toLowerCase().contains(q) ||
            c.studentClass.toLowerCase().contains(q) ||
            c.studentNisn.toLowerCase().contains(q) ||
            c.incidentLocation.toLowerCase().contains(q) ||
            c.incidentTime.toLowerCase().contains(q) ||
            c.handling.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q);
        if (!matches) return false;
      }

      return true;
    }).toList();

    // Sorting
    switch (_selectedSortOption) {
      case CaseSortOption.latest:
        list.sort(
            (a, b) => b.resolvedIncidentDate.compareTo(a.resolvedIncidentDate));
        break;
      case CaseSortOption.oldest:
        list.sort(
            (a, b) => a.resolvedIncidentDate.compareTo(b.resolvedIncidentDate));
        break;
      case CaseSortOption.highestPoints:
        list.sort((a, b) => b.violationPoints.compareTo(a.violationPoints));
        break;
    }

    return list;
  }

  bool get _hasActiveFilters =>
      _selectedChildId.isNotEmpty ||
      _selectedQuickFilter != 'Semua' ||
      _selectedCaseTypeFilter != null ||
      _selectedStatusFilter != 'Semua' ||
      _selectedSortOption != CaseSortOption.latest ||
      _searchQuery.isNotEmpty;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedQuickFilter = 'Semua';
      _selectedCaseTypeFilter = null;
      _selectedStatusFilter = 'Semua';
      _selectedSortOption = CaseSortOption.latest;
      _selectedChildId = '';
    });
    ToastNotification.show(
      context,
      message: 'Filter laporan kasus telah dikembalikan ke default.',
      type: ToastType.success,
    );
  }

  void _showFilterSortSheet() {
    String? tempCaseType = _selectedCaseTypeFilter;
    String tempStatus = _selectedStatusFilter;
    String tempChildId = _selectedChildId;
    CaseSortOption tempSort = _selectedSortOption;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalBackdrop,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool hasChanges = tempCaseType != null ||
                tempStatus != 'Semua' ||
                tempChildId.isNotEmpty ||
                tempSort != CaseSortOption.latest;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.borderMuted,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // Header Filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32.0,
                              height: 32.0,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.tune_rounded,
                                size: 16.0,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Text(
                              'Filter & Urutkan Kasus',
                              style: AppTextStyles.topBarTitle,
                            ),
                          ],
                        ),
                        if (hasChanges)
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempCaseType = null;
                                tempStatus = 'Semua';
                                tempChildId = '';
                                tempSort = CaseSortOption.latest;
                              });
                            },
                            child: Text(
                              'Reset Filter',
                              style: AppTextStyles.badgeBold10.copyWith(
                                color: AppColors.errorPrimary,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Divider(color: AppColors.borderNeutral, height: 1.0),
                    const SizedBox(height: 12.0),

                    // Opsi Filter Scrollable
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Urutkan Berdasarkan
                            const Text(
                              'Urutkan Berdasarkan',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: CaseSortOption.values.map((opt) {
                                final isSelected = tempSort == opt;
                                return GestureDetector(
                                  onTap: () =>
                                      setModalState(() => tempSort = opt),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 14.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.inputSurfaceGray,
                                      borderRadius:
                                          BorderRadius.circular(99.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryNavy
                                            : AppColors.borderNeutral,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          const Icon(
                                            Icons.check_rounded,
                                            size: 14.0,
                                            color: AppColors.pureWhite,
                                          ),
                                          const SizedBox(width: 4.0),
                                        ],
                                        Text(
                                          opt.label,
                                          style: AppTextStyles.metaSemibold12
                                              .copyWith(
                                            color: isSelected
                                                ? AppColors.pureWhite
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16.0),

                            // 2. Status Penanganan Kasus
                            const Text(
                              'Status Penanganan Kasus',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                'Semua',
                                'Dalam Proses',
                                'Selesai',
                              ].map((status) {
                                final isSelected = tempStatus == status;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => setModalState(
                                        () => tempStatus = status,
                                      ),
                                      child: Container(
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryNavy
                                              : AppColors.inputSurfaceGray,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryNavy
                                                : AppColors.borderNeutral,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          status,
                                          style: AppTextStyles.metaSemibold12
                                              .copyWith(
                                            color: isSelected
                                                ? AppColors.pureWhite
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16.0),

                            // 3. Filter Anak (jika lebih dari 1 anak)
                            if (_children.length > 1) ...[
                              const Text(
                                'Pilih Anak / Siswa',
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: 8.0),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  _buildModalChipItem(
                                    label: 'Semua Anak',
                                    isSelected: tempChildId.isEmpty,
                                    onTap: () => setModalState(
                                      () => tempChildId = '',
                                    ),
                                  ),
                                  for (final c in _children)
                                    _buildModalChipItem(
                                      label: c.name,
                                      isSelected: tempChildId == c.id,
                                      onTap: () => setModalState(
                                        () => tempChildId = c.id,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                            ],

                            // 4. Jenis Kasus Pelanggaran
                            const Text(
                              'Jenis Kasus Pelanggaran',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _caseTypeOptions.map((type) {
                                final bool isAll = type == 'Semua Jenis';
                                final bool isSelected = isAll
                                    ? tempCaseType == null
                                    : tempCaseType == type;

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempCaseType = isAll ? null : type;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 14.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.inputSurfaceGray,
                                      borderRadius:
                                          BorderRadius.circular(99.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryNavy
                                            : AppColors.borderNeutral,
                                      ),
                                    ),
                                    child: Text(
                                      type,
                                      style: AppTextStyles.metaSemibold12
                                          .copyWith(
                                        color: isSelected
                                            ? AppColors.pureWhite
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Tombol Terapkan
                    CustomButton.primary(
                      label: 'Terapkan Filter',
                      leadingIcon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        setState(() {
                          _selectedCaseTypeFilter = tempCaseType;
                          _selectedStatusFilter = tempStatus;
                          _selectedChildId = tempChildId;
                          _selectedSortOption = tempSort;
                        });
                        Navigator.of(sheetContext).pop();
                        ToastNotification.show(
                          this.context,
                          message:
                              'Filter diterapkan: ${_filteredCases.length} catatan kasus ditemukan.',
                          type: ToastType.success,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalChipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 14.0,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryNavy : AppColors.inputSurfaceGray,
          borderRadius: BorderRadius.circular(99.0),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderNeutral,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.metaSemibold12.copyWith(
            color: isSelected ? AppColors.pureWhite : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 3.0, 6.0, 3.0),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(99.0),
          border: Border.all(color: AppColors.borderNeutral),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBase.withValues(alpha: 0.02),
              offset: const Offset(0, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.subtitle11.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4.0),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                size: 13.0,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _greetingText {
    final name = AuthService.instance.currentUser?.getStringValue('name') ?? '';
    return name.isNotEmpty ? 'Halo, $name' : 'Halo, Ibu Siti Rahma';
  }

  String get _childrenSubtitle {
    if (_children.isEmpty) {
      return 'Belum ada siswa yang tertaut ke akun ini';
    }
    if (_children.length == 1) {
      final c = _children.first;
      return 'Wali dari ${c.name} • ${c.className}';
    }
    final names = _children.map((c) => c.name).join(', ');
    return 'Wali dari ${_children.length} Siswa ($names)';
  }

  void _onNavTap(int index) {
    setState(() {
      if (index == 1) _selectedCase = null; // tampilkan daftar kasus
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
      canPop: _selectedNavIndex == 0 && _selectedCase == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_selectedCase != null) {
            setState(() => _selectedCase = null);
          } else if (_selectedNavIndex != 0) {
            setState(() => _selectedNavIndex = 0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvasLightGray,
        body: AnimatedIndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildHomeContent(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.035, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _selectedCase == null
                  ? KeyedSubtree(
                      key: const ValueKey('ortu_case_list'),
                      child: _buildCaseListTab(),
                    )
                  : KeyedSubtree(
                      key: ValueKey(
                        'ortu_case_detail_${_selectedCase!.recordId.isNotEmpty ? _selectedCase!.recordId : _selectedCase!.id}',
                      ),
                      child: DetailKasusScreen(
                        caseData: _selectedCase,
                        role: ProfilRole.orangTua,
                        isReadOnly: true,
                        onBack: () => setState(() => _selectedCase = null),
                      ),
                    ),
            ),
            AjukanKonsultasiScreen(
              isEmbedded: true,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
            ProfilView(
              role: ProfilRole.orangTua,
              onLogout: _handleLogout,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedNavIndex,
          items: CustomBottomNav.ortuItems,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar Orang Tua (height: 48.0)
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
                          size: 44.0,
                          fallbackIcon: Icons.person_outline_rounded,
                          onTap: () => setState(() => _selectedNavIndex = 3),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _greetingText,
                                style: AppTextStyles.greetingActor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                _childrenSubtitle,
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
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Banner Pendampingan Positif (r=16, fill=#EBF2FF, stroke=#DBEAFE, pad=[11, 14], gap=10)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 11.0,
                horizontal: 14.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.borderBlueTint,
                  width: 1.0,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 18.0,
                    color: AppColors.primaryNavy,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Catatan bimbingan dibagikan secara transparan untuk mendukung tumbuh kembang positif ananda.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.0,
                        height: 16.0 / 11.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Section Konsultasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Konsultasi',
                  style: AppTextStyles.sectionHeader15,
                ),
                Text(
                  'Layanan Wali Murid',
                  style: AppTextStyles.captionSemibold11,
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            // Card Jadwal Konsultasi Terdekat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 15.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: AppColors.borderBlueTint,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.059),
                    offset: const Offset(0, 6),
                    blurRadius: 16.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Judul Jadwal Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Jadwal Konsultasi Terdekat',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13.0,
                          height: 18.0 / 13.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
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
                          'Tatap Muka',
                          style: AppTextStyles.badgeSemibold10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // Detail Jadwal Row
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputSurfaceGray,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38.0,
                          height: 38.0,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(11.0),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20.0,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Selasa, 10 Nov 2026 • 10:00 WIB',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12.0,
                                  height: 17.0 / 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                'Ruang BK • Ibu Dra. Nurhayati, S.Pd.',
                                style: AppTextStyles.subtitle11,
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
            const SizedBox(height: 10.0),
            // CTA Sekunder - Ajukan Konsultasi Baru
            CustomButton.secondary(
              label: 'Ajukan Konsultasi Baru',
              height: 49.0,
              onPressed: () {
                setState(() {
                  _selectedNavIndex = 2;
                });
              },
            ),

            const SizedBox(height: 16.0),

            // Section Laporan Kasus Anak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Laporan Kasus Anak',
                  style: AppTextStyles.sectionHeader15,
                ),
                Text(
                  'Semester Ganjil',
                  style: AppTextStyles.captionSemibold11,
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            ..._buildCaseCards(
              _visibleCases.take(3).toList(),
              animated: false,
            ),
            if (_visibleCases.length > 3) ...[
              const SizedBox(height: 10.0),
              CustomButton.secondary(
                label: 'Lihat Semua Kasus (${_visibleCases.length})',
                height: 44.0,
                onPressed: () => setState(() {
                  _selectedCase = null;
                  _selectedNavIndex = 1;
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _childLabel(String studentId) {
    for (final c in _children) {
      if (c.id == studentId) return c.name;
    }
    return '';
  }

  Widget _buildChildFilter() {
    if (_children.length < 2) return const SizedBox.shrink();

    Widget chip(String id, String label) {
      final selected = _selectedChildId == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
          onTap: () => setState(() => _selectedChildId = id),
          child: Container(
            height: 31.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryNavy : AppColors.pureWhite,
              borderRadius: BorderRadius.circular(99.0),
              border: selected
                  ? null
                  : Border.all(
                      color: AppColors.borderNeutral,
                      width: 1.0,
                    ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.captionSemibold11.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color:
                    selected ? AppColors.pureWhite : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            chip('', 'Semua Anak'),
            for (final c in _children) chip(c.id, c.name),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCaseCards(
    List<CaseRecordModel> list, {
    bool animated = true,
  }) {
    if (_isLoadingCases) {
      return const [
        _OrtuSkeletonCaseCard(),
        SizedBox(height: 12.0),
        _OrtuSkeletonCaseCard(),
      ];
    }
    if (_loadError != null) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.borderNeutral),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 32.0,
                color: AppColors.textPlaceholder,
              ),
              const SizedBox(height: 8.0),
              Text(
                _loadError!,
                style: AppTextStyles.subtitle11,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: _loadOrtuDataFromPocketBase,
                child: Text(
                  'Coba Lagi',
                  style: AppTextStyles.badgeBold10.copyWith(
                    color: AppColors.primaryNavy,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }
    if (list.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58.0,
                  height: 58.0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 30.0,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  _hasActiveFilters
                      ? 'Tidak ada catatan kasus yang sesuai filter.'
                      : 'Belum ada catatan kasus untuk ananda.',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4.0),
                Text(
                  _hasActiveFilters
                      ? 'Coba ubah kata kunci pencarian atau sesuaikan opsi filter.'
                      : 'Semua catatan bimbingan konseling dan tata tertib akan muncul di sini.',
                  style: AppTextStyles.subtitle11,
                  textAlign: TextAlign.center,
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(99.0),
                        border: Border.all(color: AppColors.primaryNavy),
                      ),
                      child: Text(
                        'Reset Filter Kasus',
                        style: AppTextStyles.badgeBold10.copyWith(
                          color: AppColors.primaryNavy,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < list.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i < list.length - 1 ? 12.0 : 0.0),
          child: animated
              ? TweenAnimationBuilder<double>(
                  key: ValueKey(
                    'case_${list[i].recordId.isNotEmpty ? list[i].recordId : list[i].id}_$i',
                  ),
                  duration:
                      Duration(milliseconds: 250 + (i * 45).clamp(0, 350)),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 14 * (1.0 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: CaseCard.fromModel(
                    list[i],
                    showStudentInfo: _children.length > 1,
                    onTap: () => setState(() {
                      _selectedCase = list[i];
                      _selectedNavIndex = 1;
                    }),
                  ),
                )
              : CaseCard.fromModel(
                  list[i],
                  showStudentInfo: _children.length > 1,
                  onTap: () => setState(() {
                    _selectedCase = list[i];
                    _selectedNavIndex = 1;
                  }),
                ),
        ),
    ];
  }

  /// Tab Laporan: daftar seluruh kasus milik anak wali yang sedang login
  /// dengan styling & animasi konsisten seperti KelolaKasusScreen dan DataSiswaScreen.
  Widget _buildCaseListTab() {
    final filteredList = _filteredCases;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadOrtuDataFromPocketBase,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar Laporan Kasus
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tombol Back ke Beranda
                    GestureDetector(
                      onTap: () => setState(() => _selectedNavIndex = 0),
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
                    const Expanded(
                      child: Text(
                        'Laporan Kasus',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.topBarTitle,
                      ),
                    ),
                    // Tombol Filter & Urutkan
                    GestureDetector(
                      onTap: _showFilterSortSheet,
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: _hasActiveFilters
                              ? AppColors.primaryTint
                              : AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: _hasActiveFilters
                                ? AppColors.primaryNavy
                                : AppColors.borderNeutral,
                            width: _hasActiveFilters ? 1.5 : 1.0,
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              size: 18.0,
                              color: AppColors.primaryNavy,
                            ),
                            if (_hasActiveFilters)
                              Positioned(
                                top: 1.0,
                                right: 1.0,
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color: AppColors.blueAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.pureWhite,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),

              // 3. Search Bar Kasus
              Container(
                width: double.infinity,
                height: 44.0,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 14.0,
                ),
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
                      offset: const Offset(0, 4),
                      blurRadius: 12.0,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 18.0,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Cari judul kasus, kronologi, tempat...',
                          hintStyle: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPlaceholder,
                          ),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16.0,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),

              // 4. Filter Anak (bila lebih dari 1 anak)
              _buildChildFilter(),

              // 5. Quick Horizontal Filter Chips
              SizedBox(
                height: 31.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickFilterCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final filter = _quickFilterCategories[index];
                    final bool isSelected = _selectedQuickFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedQuickFilter = filter;
                        });
                      },
                      child: Container(
                        height: 31.0,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryNavy
                              : AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(99.0),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColors.borderNeutral,
                                  width: 1.0,
                                ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter,
                          style: AppTextStyles.captionSemibold11.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.pureWhite
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 6. Active Filter Chips Row (bila ada filter aktif)
              if (_hasActiveFilters) ...[
                const SizedBox(height: 10.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              size: 12.0,
                              color: AppColors.primaryNavy,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              'Filter:',
                              style: AppTextStyles.badgeBold10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      if (_selectedSortOption != CaseSortOption.latest)
                        _buildActiveFilterChip(
                          _selectedSortOption.label,
                          () => setState(
                            () => _selectedSortOption = CaseSortOption.latest,
                          ),
                        ),
                      if (_selectedChildId.isNotEmpty)
                        _buildActiveFilterChip(
                          _childLabel(_selectedChildId).isNotEmpty
                              ? _childLabel(_selectedChildId)
                              : 'Anak Tertentu',
                          () => setState(() => _selectedChildId = ''),
                        ),
                      if (_selectedQuickFilter != 'Semua')
                        _buildActiveFilterChip(
                          _selectedQuickFilter,
                          () => setState(() => _selectedQuickFilter = 'Semua'),
                        ),
                      if (_selectedStatusFilter != 'Semua')
                        _buildActiveFilterChip(
                          _selectedStatusFilter,
                          () => setState(() => _selectedStatusFilter = 'Semua'),
                        ),
                      if (_selectedCaseTypeFilter != null)
                        _buildActiveFilterChip(
                          _selectedCaseTypeFilter!,
                          () => setState(() => _selectedCaseTypeFilter = null),
                        ),
                      if (_searchQuery.isNotEmpty)
                        _buildActiveFilterChip(
                          '"$_searchQuery"',
                          () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                        ),
                      const SizedBox(width: 4.0),
                      GestureDetector(
                        onTap: _resetFilters,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 6.0,
                          ),
                          child: Text(
                            'Reset',
                            style: AppTextStyles.captionSemibold11.copyWith(
                              color: AppColors.errorPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14.0),

              // 7. Header Info & Counter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Catatan Kasus (${filteredList.length})',
                    style: AppTextStyles.cardTitle,
                  ),
                  const Text(
                    'Semester Ganjil',
                    style: AppTextStyles.captionSemibold11,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // 8. Daftar Kartu Kasus dengan Animasi Kemunculan
              ..._buildCaseCards(filteredList, animated: true),
            ],
          ),
        ),
      ),
    );
  }
}
