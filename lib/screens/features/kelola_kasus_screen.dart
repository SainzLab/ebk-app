import 'package:flutter/material.dart';
import '../../models/case_model.dart';
import '../../repositories/case_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/toast_notification.dart';
import '../states/delete_dialog.dart';
import 'detail_kasus_screen.dart';
import 'tambah_kasus_screen.dart';

enum CaseSortOption {
  latest('Terbaru (Waktu Kejadian)'),
  oldest('Terlama (Waktu Kejadian)'),
  highestPoints('Poin Tertinggi (Berat ke Ringan)'),
  studentNameAsc('Nama Siswa (A – Z)');

  final String label;
  const CaseSortOption(this.label);
}

/// Halaman Kelola Data Kasus Pelanggaran Siswa (`SRS-F-004`, `SRS-F-008`, `SRS-F-009`)
/// Menyediakan fitur melihat, menambah, mengedit, serta memfilter data kasus
/// pelanggaran (membolos, tawuran, waktu, tempat, status penanganan Guru BK).
class KelolaKasusScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<CaseRecordModel>? onOpenDetail;
  final ValueChanged<CaseRecordModel?>? onOpenTambah;

  const KelolaKasusScreen({
    super.key,
    this.onBack,
    this.onOpenDetail,
    this.onOpenTambah,
  });

  @override
  State<KelolaKasusScreen> createState() => _KelolaKasusScreenState();
}

class _KelolaKasusScreenState extends State<KelolaKasusScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedQuickFilter = 'Semua';
  String? _selectedCaseTypeFilter;
  String _selectedStatusFilter = 'Semua';
  String _selectedGradeFilter = 'Semua';
  CaseSortOption _selectedSortOption = CaseSortOption.latest;
  String _searchQuery = '';

  late List<CaseRecordModel> _cases;

  static const List<String> _quickFilterCategories = [
    'Semua',
    'Membolos',
    'Tawuran',
    'Kedisiplinan',
    'Dalam Proses',
    'Selesai',
  ];

  static const List<String> _caseTypeOptions = [
    'Semua Jenis',
    'Membolos',
    'Tawuran',
    'Atribut Seragam',
    'Keterlambatan',
    'Merokok / Vape',
    'Perundungan',
  ];

  static const List<String> _gradeOptions = [
    'Semua',
    'Kelas VII',
    'Kelas VIII',
    'Kelas IX',
  ];

  @override
  void initState() {
    super.initState();
    _cases = List.from(CaseRecordModel.defaultCases);
    _loadCasesFromPocketBase();
  }

  Future<void> _loadCasesFromPocketBase() async {
    try {
      final list = await CaseRepository.instance.getCases();
      if (mounted) {
        setState(() {
          _cases = list;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedCaseTypeFilter != null ||
      _selectedStatusFilter != 'Semua' ||
      _selectedGradeFilter != 'Semua' ||
      _selectedSortOption != CaseSortOption.latest;

  List<CaseRecordModel> get _filteredCases {
    final q = _searchQuery.trim().toLowerCase();
    final list = _cases.where((c) {
      // 1. Quick horizontal filter chip
      bool matchesQuick = true;
      if (_selectedQuickFilter == 'Membolos') {
        matchesQuick = c.caseTitle.toLowerCase().contains('membolos');
      } else if (_selectedQuickFilter == 'Tawuran') {
        matchesQuick = c.caseTitle.toLowerCase().contains('tawuran') ||
            c.caseTitle.toLowerCase().contains('perkelahian');
      } else if (_selectedQuickFilter == 'Kedisiplinan') {
        matchesQuick = c.caseCategory.toLowerCase().contains('disiplin');
      } else if (_selectedQuickFilter == 'Dalam Proses') {
        matchesQuick = !c.isCompleted;
      } else if (_selectedQuickFilter == 'Selesai') {
        matchesQuick = c.isCompleted;
      }

      // 2. Specific case type filter
      bool matchesCaseType = true;
      if (_selectedCaseTypeFilter != null) {
        matchesCaseType = c.caseTitle
            .toLowerCase()
            .contains(_selectedCaseTypeFilter!.toLowerCase());
      }

      // 3. Status filter
      bool matchesStatus = true;
      if (_selectedStatusFilter == 'Dalam Proses') {
        matchesStatus = !c.isCompleted;
      } else if (_selectedStatusFilter == 'Selesai') {
        matchesStatus = c.isCompleted;
      }

      // 4. Grade filter
      bool matchesGrade = true;
      if (_selectedGradeFilter != 'Semua') {
        matchesGrade = c.studentClass.startsWith(_selectedGradeFilter);
      }

      // 5. Search query
      final matchesSearch = q.isEmpty ||
          c.studentName.toLowerCase().contains(q) ||
          c.studentNisn.contains(q) ||
          c.id.toLowerCase().contains(q) ||
          c.caseTitle.toLowerCase().contains(q) ||
          c.incidentLocation.toLowerCase().contains(q) ||
          c.incidentTime.toLowerCase().contains(q) ||
          c.handling.toLowerCase().contains(q);

      return matchesQuick &&
          matchesCaseType &&
          matchesStatus &&
          matchesGrade &&
          matchesSearch;
    }).toList();

    // Sorting
    switch (_selectedSortOption) {
      case CaseSortOption.latest:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
      case CaseSortOption.oldest:
        list.sort((a, b) => a.id.compareTo(b.id));
        break;
      case CaseSortOption.highestPoints:
        list.sort((a, b) => b.violationPoints.compareTo(a.violationPoints));
        break;
      case CaseSortOption.studentNameAsc:
        list.sort((a, b) =>
            a.studentName.toLowerCase().compareTo(b.studentName.toLowerCase()));
        break;
    }

    return list;
  }

  void _resetFilters() {
    setState(() {
      _selectedCaseTypeFilter = null;
      _selectedStatusFilter = 'Semua';
      _selectedGradeFilter = 'Semua';
      _selectedSortOption = CaseSortOption.latest;
    });
    ToastNotification.show(
      context,
      message: 'Filter kasus telah dikembalikan ke default.',
      type: ToastType.success,
    );
  }

  void _showFilterSortSheet() {
    String? tempCaseType = _selectedCaseTypeFilter;
    String tempStatus = _selectedStatusFilter;
    String tempGrade = _selectedGradeFilter;
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
                tempGrade != 'Semua' ||
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
                                tempGrade = 'Semua';
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
                                  onTap: () {
                                    setModalState(() {
                                      tempSort = opt;
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
                                      borderRadius: BorderRadius.circular(99.0),
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

                            // 2. Jenis Kasus Pelanggaran
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
                                      borderRadius: BorderRadius.circular(99.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryNavy
                                            : AppColors.borderNeutral,
                                      ),
                                    ),
                                    child: Text(
                                      type,
                                      style:
                                          AppTextStyles.metaSemibold12.copyWith(
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

                            // 3. Status Penanganan Kasus
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
                                      onTap: () {
                                        setModalState(() {
                                          tempStatus = status;
                                        });
                                      },
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
                                          status == 'Selesai'
                                              ? 'Selesai Dibina'
                                              : status,
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

                            // 4. Tingkat Kelas Siswa
                            const Text(
                              'Tingkat Kelas Siswa',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _gradeOptions.map((g) {
                                final isSelected = tempGrade == g;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempGrade = g;
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
                                      borderRadius: BorderRadius.circular(99.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryNavy
                                            : AppColors.borderNeutral,
                                      ),
                                    ),
                                    child: Text(
                                      g,
                                      style:
                                          AppTextStyles.metaSemibold12.copyWith(
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

                    // Tombol Terapkan Filter
                    CustomButton.primary(
                      label: 'Terapkan Filter Kasus',
                      leadingIcon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        setState(() {
                          _selectedCaseTypeFilter = tempCaseType;
                          _selectedStatusFilter = tempStatus;
                          _selectedGradeFilter = tempGrade;
                          _selectedSortOption = tempSort;
                        });
                        Navigator.of(sheetContext).pop();
                        ToastNotification.show(
                          this.context,
                          message:
                              'Filter diterapkan: ${_filteredCases.length} kasus ditemukan.',
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

  void _openTambahKasus() async {
    if (widget.onOpenTambah != null) {
      widget.onOpenTambah!(null);
      return;
    }
    final result = await Navigator.push<CaseRecordModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahKasusScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _cases.insert(0, result);
      });
      ToastNotification.show(
        context,
        message: 'Berhasil: Kasus ${result.caseTitle} telah dicatat.',
        type: ToastType.success,
      );
    }
  }

  void _openEditKasus(CaseRecordModel caseToEdit) async {
    if (widget.onOpenTambah != null) {
      widget.onOpenTambah!(caseToEdit);
      return;
    }
    final result = await Navigator.push<CaseRecordModel>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahKasusScreen(initialCase: caseToEdit),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final idx = _cases.indexWhere((c) => c.id == result.id);
        if (idx != -1) {
          _cases[idx] = result;
        }
      });
      ToastNotification.show(
        context,
        message: 'Berhasil: Data kasus ${result.id} telah diperbarui.',
        type: ToastType.success,
      );
    }
  }

  void _openDetailKasus(CaseRecordModel caseItem) async {
    if (widget.onOpenDetail != null) {
      widget.onOpenDetail!(caseItem);
      return;
    }
    final updated = await Navigator.push<CaseRecordModel>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailKasusScreen(caseData: caseItem),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final idx = _cases.indexWhere((c) => c.id == updated.id);
        if (idx != -1) {
          _cases[idx] = updated;
        }
      });
    }
  }

  Future<void> _deleteCase(CaseRecordModel caseItem) async {
    final confirmed = await DeleteDialog.show(
      context,
      title: 'Hapus Catatan Kasus?',
      message:
          'Apakah Anda yakin ingin menghapus data kasus ${caseItem.id} (${caseItem.caseTitle} - ${caseItem.studentName}) secara permanen?',
    );

    if (confirmed == true && mounted) {
      try {
        await CaseRepository.instance.deleteCase(caseItem);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _cases.removeWhere((c) => c.id == caseItem.id);
      });
      ToastNotification.show(
        context,
        message: 'Berhasil: Laporan kasus ${caseItem.id} telah dihapus.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredCases;

    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar Kelola Data Kasus (height: 44.0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tombol Back
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
                        const Expanded(
                          child: Text(
                            'Kelola Data Kasus',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.topBarTitle,
                          ),
                        ),
                        // Filter Sort Icon Button di Kanan Atas (40x40, r=12)
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
                                  color: AppColors.shadowBase
                                      .withValues(alpha: 0.031),
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
                  const SizedBox(height: 12.0),

                  // Search Bar Kasus
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
                              hintText:
                                  'Cari nama, jenis kasus (membolos, tawuran), tempat...',
                              hintStyle: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPlaceholder,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Filter Chips Cepat Kategori & Status
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                            ),
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

                  // Tag Filter Aktif (bila ada filter modal aktif)
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
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 12.0,
                                  color: AppColors.primaryNavy,
                                ),
                                const SizedBox(width: 4.0),
                                const Text(
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
                              () => setState(() =>
                                  _selectedSortOption = CaseSortOption.latest),
                            ),
                          if (_selectedCaseTypeFilter != null)
                            _buildActiveFilterChip(
                              _selectedCaseTypeFilter!,
                              () => setState(
                                  () => _selectedCaseTypeFilter = null),
                            ),
                          if (_selectedStatusFilter != 'Semua')
                            _buildActiveFilterChip(
                              _selectedStatusFilter,
                              () => setState(
                                  () => _selectedStatusFilter = 'Semua'),
                            ),
                          if (_selectedGradeFilter != 'Semua')
                            _buildActiveFilterChip(
                              _selectedGradeFilter,
                              () => setState(
                                  () => _selectedGradeFilter = 'Semua'),
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

                  const SizedBox(height: 12.0),

                  // Header List Kasus
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Daftar Kasus Pelanggaran (${filteredList.length})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'TP 2026/2027',
                        style: AppTextStyles.captionSemibold11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // List Kartu Kasus Pelanggaran
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadCasesFromPocketBase,
                      child: filteredList.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height: 320.0,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      size: 42.0,
                                      color: AppColors.textPlaceholder,
                                    ),
                                    const SizedBox(height: 8.0),
                                    const Text(
                                      'Tidak ada catatan kasus yang sesuai filter.',
                                      style: AppTextStyles.body,
                                    ),
                                    if (_hasActiveFilters) ...[
                                      const SizedBox(height: 8.0),
                                      GestureDetector(
                                        onTap: _resetFilters,
                                        child: Text(
                                          'Reset Filter Kasus',
                                          style: AppTextStyles.badgeBold10.copyWith(
                                            color: AppColors.primaryNavy,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 80.0),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12.0),
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return _CaseItemCard(
                                  caseItem: item,
                                  onTapDetail: () => _openDetailKasus(item),
                                  onEdit: () => _openEditKasus(item),
                                  onDelete: () => _deleteCase(item),
                                );
                              },
                            ),
                    ),
                  ),

                  // Home Indicator
                  Center(
                    child: Container(
                      width: 134.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: AppColors.borderMuted,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FAB Tambah Kasus (+) (58x58, r=18, fill=#1B3B7B)
            Positioned(
              right: 20.0,
              bottom: 28.0,
              child: GestureDetector(
                onTap: _openTambahKasus,
                child: Container(
                  width: 58.0,
                  height: 58.0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(18.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.32),
                        offset: const Offset(0, 8),
                        blurRadius: 20.0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add_rounded,
                    size: 26.0,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseItemCard extends StatelessWidget {
  final CaseRecordModel caseItem;
  final VoidCallback onTapDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CaseItemCard({
    required this.caseItem,
    required this.onTapDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = caseItem.isCompleted;

    final Color badgeBg =
        isCompleted ? AppColors.successBg : AppColors.warningBg;
    final Color badgeText =
        isCompleted ? AppColors.successText : AppColors.warningText;
    final String badgeLabel = isCompleted ? 'Selesai' : 'Dalam Proses';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20.0),
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
          onTap: onTapDetail,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Baris ID, Kategori, & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
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
                              caseItem.id,
                              style: AppTextStyles.badgeBold10,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(6.0),
                                border:
                                    Border.all(color: AppColors.borderNeutral),
                              ),
                              child: Text(
                                caseItem.caseCategory,
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
                    ),
                    const SizedBox(width: 8.0),
                    // Badge Status Selesai / Dalam Proses
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        badgeLabel,
                        style: AppTextStyles.captionSemibold11.copyWith(
                          color: badgeText,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Judul Kasus Pelanggaran (misal: Membolos / Tawuran)
                Text(
                  caseItem.caseTitle,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 14.0,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4.0),

                // Siswa & Kelas Terkait
                Text(
                  '${caseItem.studentName} • ${caseItem.studentClass} (${caseItem.studentNisn})',
                  style: AppTextStyles.subtitle11.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10.0),

                // Baris Waktu Kejadian
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14.0,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        caseItem.incidentTime,
                        style: AppTextStyles.paragraph12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),

                // Baris Tempat Kejadian
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14.0,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        caseItem.incidentLocation,
                        style: AppTextStyles.paragraph12.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Kotak Catatan Penanganan Guru BK
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppColors.inputSurfaceGray,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 15.0,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Penanganan: ${caseItem.handling}',
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
                const SizedBox(height: 12.0),

                // Baris Aksi Footer: Poin, Edit, Hapus, & Detail
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Poin Pelanggaran Badge
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
                        '+${caseItem.violationPoints} Poin',
                        style: AppTextStyles.badgeBold10.copyWith(
                          color: AppColors.errorPrimary,
                        ),
                      ),
                    ),

                    // Tombol Aksi (Hapus, Edit, Detail)
                    Row(
                      children: [
                        // Tombol Hapus
                        IconButton(
                          iconSize: 18.0,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        // Tombol Edit
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: AppColors.borderNeutral,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 13.0,
                                  color: AppColors.primaryNavy,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Edit',
                                  style:
                                      AppTextStyles.badgeSemibold10.copyWith(
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Tombol Detail
                        GestureDetector(
                          onTap: onTapDetail,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Detail',
                                  style: AppTextStyles.badgeBold10.copyWith(
                                    fontSize: 11.0,
                                  ),
                                ),
                                const SizedBox(width: 2.0),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14.0,
                                  color: AppColors.primaryNavy,
                                ),
                              ],
                            ),
                          ),
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
