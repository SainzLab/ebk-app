import 'package:flutter/material.dart';
import '../../models/counseling_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';

class _WeekDayItem {
  final String dayName;
  final String dateNum;

  const _WeekDayItem({
    required this.dayName,
    required this.dateNum,
  });
}

/// Halaman Kelola Layanan Konseling (`08 • Jadwal Konseling (SRS-F-005)`)
/// Berdasarkan spesifikasi `08-jadwal-konseling-srs-f-005.png` dan `ebk_design.json`.
/// Mendukung fitur lengkap:
/// 1. Melihat jadwal bimbingan konseling harian/mingguan.
/// 2. Menetapkan / mengubah jenis konseling (Individu, Kelompok, Akademik, Karir, Sosial).
/// 3. Mencatat hasil konseling & evaluasi.
/// 4. Mencatat rencana tindak lanjut pembinaan siswa.
/// 5. Memperbarui status layanan (Dalam Proses / Selesai) tanpa dot.
/// 6. Filter & pengurutan interaktif (modal bottom sheet, active tags, dan quick chips).
class JadwalKonselingScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const JadwalKonselingScreen({
    super.key,
    this.onBack,
  });

  @override
  State<JadwalKonselingScreen> createState() => _JadwalKonselingScreenState();
}

class _JadwalKonselingScreenState extends State<JadwalKonselingScreen> {
  // Master Data Layanan Konseling
  late List<CounselingModel> _sessions;

  // Navigasi Kalender Mingguan
  int _selectedDayIndex = 5; // Sab 07 Nov
  bool _filterByDay = true;

  // Controller Pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter Kriteria
  String _selectedQuickFilter = 'Semua Sesi';
  String _sortBy = 'Waktu (Paling Pagi / Awal)';
  String _selectedCategoryFilter = 'Semua Jenis';
  String _selectedStatusFilter = 'Semua';
  String _selectedClassFilter = 'Semua';

  static const List<_WeekDayItem> _weekDays = [
    _WeekDayItem(dayName: 'Sen', dateNum: '02'),
    _WeekDayItem(dayName: 'Sel', dateNum: '03'),
    _WeekDayItem(dayName: 'Rab', dateNum: '04'),
    _WeekDayItem(dayName: 'Kam', dateNum: '05'),
    _WeekDayItem(dayName: 'Jum', dateNum: '06'),
    _WeekDayItem(dayName: 'Sab', dateNum: '07'),
    _WeekDayItem(dayName: 'Min', dateNum: '08'),
  ];

  static const List<String> _quickFilterChips = [
    'Semua Sesi',
    'Dalam Proses',
    'Selesai',
    'Individu',
    'Kelompok',
    'Belajar / Akademik',
    'Sosial / Perilaku',
    'Karir',
  ];

  static const List<String> _counselingTypes = [
    'Individu',
    'Kelompok',
    'Belajar / Akademik',
    'Karir',
    'Sosial / Perilaku',
  ];

  static const List<Map<String, String>> _availableStudents = [
    {'name': 'Rizky Pratama', 'class': 'Kelas IX-B', 'nisn': '0081234567'},
    {'name': 'Alya Putri Maharani', 'class': 'Kelas VIII-A', 'nisn': '0098765432'},
    {'name': 'Dimas Aditya Saputra', 'class': 'Kelas VII-C', 'nisn': '0105678912'},
    {'name': 'Farhan Maulana', 'class': 'Kelas IX-A', 'nisn': '0087654321'},
    {'name': 'Siti Nurhaliza', 'class': 'Kelas VIII-B', 'nisn': '0091238901'},
    {'name': 'Budi Santoso', 'class': 'Kelas VII-A', 'nisn': '0103456789'},
  ];

  @override
  void initState() {
    super.initState();
    _sessions = CounselingModel.getInitialSessions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _selectedQuickFilter != 'Semua Sesi' ||
        _sortBy != 'Waktu (Paling Pagi / Awal)' ||
        _selectedCategoryFilter != 'Semua Jenis' ||
        _selectedStatusFilter != 'Semua' ||
        _selectedClassFilter != 'Semua' ||
        !_filterByDay ||
        _searchQuery.isNotEmpty;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedQuickFilter = 'Semua Sesi';
      _sortBy = 'Waktu (Paling Pagi / Awal)';
      _selectedCategoryFilter = 'Semua Jenis';
      _selectedStatusFilter = 'Semua';
      _selectedClassFilter = 'Semua';
      _filterByDay = true;
      _selectedDayIndex = 5;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<CounselingModel> get _filteredSessions {
    final list = _sessions.where((session) {
      // Filter Tanggal Mingguan (bila aktif)
      if (_filterByDay && session.dayIndex != _selectedDayIndex) {
        return false;
      }

      // Filter Pencarian Teks
      if (_searchQuery.isNotEmpty) {
        final matches = session.studentName.toLowerCase().contains(_searchQuery) ||
            session.studentClass.toLowerCase().contains(_searchQuery) ||
            session.studentNisn.contains(_searchQuery) ||
            session.topic.toLowerCase().contains(_searchQuery) ||
            session.counselingType.toLowerCase().contains(_searchQuery) ||
            session.resultNotes.toLowerCase().contains(_searchQuery) ||
            session.followUpPlan.toLowerCase().contains(_searchQuery);
        if (!matches) return false;
      }

      // Quick Chips Filter
      if (_selectedQuickFilter == 'Dalam Proses' && session.isCompleted) {
        return false;
      }
      if (_selectedQuickFilter == 'Selesai' && !session.isCompleted) {
        return false;
      }
      if (_selectedQuickFilter == 'Individu' && session.counselingType != 'Individu') {
        return false;
      }
      if (_selectedQuickFilter == 'Kelompok' && session.counselingType != 'Kelompok') {
        return false;
      }
      if (_selectedQuickFilter == 'Belajar / Akademik' &&
          !session.counselingType.toLowerCase().contains('akademik') &&
          !session.counselingType.toLowerCase().contains('belajar')) {
        return false;
      }
      if (_selectedQuickFilter == 'Sosial / Perilaku' &&
          !session.counselingType.toLowerCase().contains('sosial') &&
          !session.counselingType.toLowerCase().contains('perilaku')) {
        return false;
      }
      if (_selectedQuickFilter == 'Karir' && session.counselingType != 'Karir') {
        return false;
      }

      // Filter Kategori dari Modal Sheet
      if (_selectedCategoryFilter != 'Semua Jenis' &&
          session.counselingType != _selectedCategoryFilter) {
        return false;
      }

      // Filter Status dari Modal Sheet
      if (_selectedStatusFilter == 'Dalam Proses' && session.isCompleted) {
        return false;
      }
      if (_selectedStatusFilter == 'Selesai' && !session.isCompleted) {
        return false;
      }

      // Filter Tingkat Kelas
      if (_selectedClassFilter == 'Kelas VII' &&
          !session.studentClass.contains('VII-')) {
        return false;
      }
      if (_selectedClassFilter == 'Kelas VIII' &&
          !session.studentClass.contains('VIII-')) {
        return false;
      }
      if (_selectedClassFilter == 'Kelas IX' &&
          !session.studentClass.contains('IX-')) {
        return false;
      }

      return true;
    }).toList();

    // Pengurutan (Sorting)
    if (_sortBy == 'Waktu (Paling Pagi / Awal)') {
      list.sort((a, b) => a.timeRange.compareTo(b.timeRange));
    } else if (_sortBy == 'Waktu (Paling Siang / Akhir)') {
      list.sort((a, b) => b.timeRange.compareTo(a.timeRange));
    } else if (_sortBy == 'Nama Siswa (A – Z)') {
      list.sort((a, b) => a.studentName.compareTo(b.studentName));
    } else if (_sortBy == 'Jenis Konseling') {
      list.sort((a, b) => a.counselingType.compareTo(b.counselingType));
    }

    return list;
  }

  // Aksi Toggle Status Cepat (Proses / Selesai)
  void _toggleSessionStatus(CounselingModel session) {
    setState(() {
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        final newStatus = !_sessions[index].isCompleted;
        _sessions[index] = _sessions[index].copyWith(isCompleted: newStatus);

        ToastNotification.show(
          context,
          message: newStatus
              ? 'Layanan ${session.id} diselesaikan.'
              : 'Status layanan ${session.id} dibuka kembali (Dalam Proses).',
          type: ToastType.success,
        );
      }
    });
  }

  // Modal Bottom Sheet: Filter & Urutan
  void _showFilterSortSheet() {
    String tempSort = _sortBy;
    String tempCategory = _selectedCategoryFilter;
    String tempStatus = _selectedStatusFilter;
    String tempClass = _selectedClassFilter;
    bool tempFilterByDay = _filterByDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 18.0,
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.borderNeutral,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // Title & Reset Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Urutkan Layanan',
                          style: AppTextStyles.heading2,
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSort = 'Waktu (Paling Pagi / Awal)';
                              tempCategory = 'Semua Jenis';
                              tempStatus = 'Semua';
                              tempClass = 'Semua';
                              tempFilterByDay = true;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),

                    // Opsi Tampilan Hari
                    const Text('Rentang Tampilan', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Hari Terpilih Saja',
                            isSelected: tempFilterByDay,
                            onTap: () =>
                                setModalState(() => tempFilterByDay = true),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Semua Hari (Minggu Ini)',
                            isSelected: !tempFilterByDay,
                            onTap: () =>
                                setModalState(() => tempFilterByDay = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Urutkan Berdasarkan
                    const Text('Urutkan Berdasarkan', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        'Waktu (Paling Pagi / Awal)',
                        'Waktu (Paling Siang / Akhir)',
                        'Nama Siswa (A – Z)',
                        'Jenis Konseling',
                      ].map((sortOption) {
                        return _FilterOptionChip(
                          label: sortOption,
                          isSelected: tempSort == sortOption,
                          onTap: () =>
                              setModalState(() => tempSort = sortOption),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Filter Jenis Konseling
                    const Text('Jenis Konseling', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        'Semua Jenis',
                        'Individu',
                        'Kelompok',
                        'Belajar / Akademik',
                        'Karir',
                        'Sosial / Perilaku',
                      ].map((type) {
                        return _FilterOptionChip(
                          label: type,
                          isSelected: tempCategory == type,
                          onTap: () =>
                              setModalState(() => tempCategory = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Filter Status Layanan
                    const Text('Status Layanan', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Semua',
                            isSelected: tempStatus == 'Semua',
                            onTap: () =>
                                setModalState(() => tempStatus = 'Semua'),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Dalam Proses',
                            isSelected: tempStatus == 'Dalam Proses',
                            onTap: () => setModalState(
                                () => tempStatus = 'Dalam Proses'),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Selesai',
                            isSelected: tempStatus == 'Selesai',
                            onTap: () =>
                                setModalState(() => tempStatus = 'Selesai'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Filter Tingkat Kelas
                    const Text('Tingkat Kelas', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Semua',
                            isSelected: tempClass == 'Semua',
                            onTap: () =>
                                setModalState(() => tempClass = 'Semua'),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Kelas VII',
                            isSelected: tempClass == 'Kelas VII',
                            onTap: () =>
                                setModalState(() => tempClass = 'Kelas VII'),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Kelas VIII',
                            isSelected: tempClass == 'Kelas VIII',
                            onTap: () =>
                                setModalState(() => tempClass = 'Kelas VIII'),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: _FilterOptionChip(
                            label: 'Kelas IX',
                            isSelected: tempClass == 'Kelas IX',
                            onTap: () =>
                                setModalState(() => tempClass = 'Kelas IX'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Tombol Terapkan Filter
                    CustomButton(
                      label: 'Terapkan Filter',
                      height: 50.0,
                      onPressed: () {
                        setState(() {
                          _sortBy = tempSort;
                          _selectedCategoryFilter = tempCategory;
                          _selectedStatusFilter = tempStatus;
                          _selectedClassFilter = tempClass;
                          _filterByDay = tempFilterByDay;
                        });
                        Navigator.pop(ctx);
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

  // Modal Bottom Sheet: Menetapkan Jenis, Mencatat Hasil, Tindak Lanjut & Status
  void _showRecordResultSheet(CounselingModel session) {
    String selectedType = session.counselingType;
    final topicCtrl = TextEditingController(text: session.topic);
    final resultsCtrl = TextEditingController(text: session.resultNotes);
    final followUpCtrl = TextEditingController(text: session.followUpPlan);
    bool isCompletedStatus = session.isCompleted;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 18.0,
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.borderNeutral,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // Header Info Siswa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                      session.id,
                                      style: AppTextStyles.badgeBold10,
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text(
                                    session.timeRange,
                                    style: AppTextStyles.subtitle11,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                session.studentName,
                                style: AppTextStyles.heading2,
                              ),
                              Text(
                                '${session.studentClass} • NISN: ${session.studentNisn}',
                                style: AppTextStyles.bodySmall11,
                              ),
                            ],
                          ),
                        ),
                        // Status Badge (Tanpa Dot)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: isCompletedStatus
                                ? AppColors.successBg
                                : AppColors.warningBg,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          child: Text(
                            isCompletedStatus ? 'Selesai' : 'Dalam Proses',
                            style: AppTextStyles.captionSemibold11.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isCompletedStatus
                                  ? AppColors.successText
                                  : AppColors.warningText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18.0),
                    const Divider(height: 1.0, color: AppColors.borderNeutral),
                    const SizedBox(height: 16.0),

                    // 1. Menetapkan Jenis Konseling
                    const Text('1. Menetapkan Jenis Konseling',
                        style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _counselingTypes.map((type) {
                        return _FilterOptionChip(
                          label: type,
                          isSelected: selectedType == type,
                          onTap: () =>
                              setSheetState(() => selectedType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // 2. Topik Bimbingan
                    const Text('2. Topik Konseling', style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    CustomTextField(
                      controller: topicCtrl,
                      hintText: 'Masukkan fokus topik bimbingan konseling',
                      prefixIcon: Icons.menu_book_rounded,
                    ),
                    const SizedBox(height: 16.0),

                    // 3. Mencatat Hasil Konseling
                    const Text('3. Catatan Hasil Konseling / Diskusi',
                        style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: AppColors.borderNeutral,
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: resultsCtrl,
                        maxLines: 3,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText:
                              'Catat evaluasi, hasil diskusi, dan respons keterbukaan siswa...',
                          hintStyle: AppTextStyles.body,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 4. Tindak Lanjut Pembinaan
                    const Text('4. Rencana Tindak Lanjut Siswa',
                        style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: AppColors.borderNeutral,
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: followUpCtrl,
                        maxLines: 3,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText:
                              'Tuliskan langkah pemantauan berkala, koordinasi wali kelas/ortu...',
                          hintStyle: AppTextStyles.body,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 5. Memperbarui Status Kasus / Layanan (Tanpa Dot)
                    const Text('5. Status Layanan Konseling',
                        style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setSheetState(() => isCompletedStatus = false),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: !isCompletedStatus
                                    ? AppColors.warningBg
                                    : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: !isCompletedStatus
                                      ? AppColors.warningAccent
                                      : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Dalam Proses',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: !isCompletedStatus
                                      ? AppColors.warningText
                                      : AppColors.textSecondary,
                                  fontWeight: !isCompletedStatus
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setSheetState(() => isCompletedStatus = true),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: isCompletedStatus
                                    ? AppColors.successBg
                                    : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isCompletedStatus
                                      ? AppColors.successBorder
                                      : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Selesai Dibina',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: isCompletedStatus
                                      ? AppColors.successText
                                      : AppColors.textSecondary,
                                  fontWeight: isCompletedStatus
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Tombol Simpan
                    CustomButton(
                      label: 'Simpan Pembinaan & Hasil',
                      height: 50.0,
                      onPressed: () {
                        setState(() {
                          final idx = _sessions
                              .indexWhere((s) => s.id == session.id);
                          if (idx != -1) {
                            _sessions[idx] = _sessions[idx].copyWith(
                              counselingType: selectedType,
                              topic: topicCtrl.text.trim().isEmpty
                                  ? session.topic
                                  : topicCtrl.text.trim(),
                              resultNotes: resultsCtrl.text.trim(),
                              followUpPlan: followUpCtrl.text.trim(),
                              isCompleted: isCompletedStatus,
                            );
                          }
                        });
                        Navigator.pop(ctx);
                        ToastNotification.show(
                          context,
                          message:
                              'Berhasil: Catatan hasil dan status layanan ${session.id} telah diperbarui.',
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

  // Modal Bottom Sheet: Tambah Layanan Konseling Baru
  void _showAddScheduleSheet() {
    Map<String, String> selectedStudent = _availableStudents.first;
    String selectedType = _counselingTypes.first;
    final topicCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00 – 09:45 WIB');
    int selectedDay = _selectedDayIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 18.0,
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.borderNeutral,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    const Text(
                      'Jadwalkan Layanan Konseling Baru',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 14.0),

                    // 1. Pilih Siswa
                    const Text('Pilih Siswa', style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: AppColors.borderNeutral,
                          width: 1.0,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, String>>(
                          value: selectedStudent,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryNavy,
                          ),
                          items: _availableStudents.map((s) {
                            return DropdownMenuItem<Map<String, String>>(
                              value: s,
                              child: Text(
                                '${s['name']} • ${s['class']} (${s['nisn']})',
                                style: AppTextStyles.body,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedStudent = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 2. Jenis Konseling
                    const Text('Jenis Konseling', style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _counselingTypes.map((type) {
                        return _FilterOptionChip(
                          label: type,
                          isSelected: selectedType == type,
                          onTap: () => setModalState(() => selectedType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14.0),

                    // 3. Hari Konseling
                    const Text('Pilih Hari (Pekan Ini)',
                        style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_weekDays.length, (idx) {
                          final item = _weekDays[idx];
                          final isSel = selectedDay == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () => setModalState(() => selectedDay = idx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.primaryNavy
                                      : AppColors.canvasLightGray,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  '${item.dayName} ${item.dateNum} Nov',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: isSel
                                        ? AppColors.pureWhite
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Jam / Waktu Pelaksanaan
                    const Text('Waktu Pelaksanaan', style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    CustomTextField(
                      controller: timeCtrl,
                      hintText: 'Contoh: 09:30 – 10:15 WIB',
                      prefixIcon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 14.0),

                    // 5. Topik Konseling
                    const Text('Topik Bimbingan', style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    CustomTextField(
                      controller: topicCtrl,
                      hintText: 'Contoh: Pembinaan Motivasi dan Kedisiplinan Belajar',
                      prefixIcon: Icons.assignment_outlined,
                    ),
                    const SizedBox(height: 24.0),

                    // Tombol Simpan Jadwal Baru
                    CustomButton(
                      label: 'Jadwalkan Layanan',
                      height: 50.0,
                      onPressed: () {
                        if (topicCtrl.text.trim().isEmpty) {
                          ToastNotification.show(
                            context,
                            message: 'Peringatan: Mohon lengkapi topik bimbingan.',
                            type: ToastType.error,
                          );
                          return;
                        }

                        final newId = 'KSL-0${_sessions.length + 1}';
                        final newSession = CounselingModel(
                          id: newId,
                          studentName: selectedStudent['name']!,
                          studentClass: selectedStudent['class']!,
                          studentNisn: selectedStudent['nisn']!,
                          dateStr:
                              '${_weekDays[selectedDay].dayName}, ${_weekDays[selectedDay].dateNum} Nov 2026',
                          dayIndex: selectedDay,
                          timeRange: timeCtrl.text.trim().isEmpty
                              ? '09:00 – 09:45 WIB'
                              : timeCtrl.text.trim(),
                          counselingType: selectedType,
                          topic: topicCtrl.text.trim(),
                          isCompleted: false,
                        );

                        setState(() {
                          _sessions.insert(0, newSession);
                          _selectedDayIndex = selectedDay;
                        });

                        Navigator.pop(ctx);
                        ToastNotification.show(
                          context,
                          message:
                              'Berhasil: Jadwal konseling baru untuk ${newSession.studentName} telah ditambahkan.',
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

  // Modal Sheet: Detail Lengkap Layanan Konseling
  void _showDetailSheet(CounselingModel session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 18.0,
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.borderNeutral,
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),

                // Baris ID & Status (Tanpa Dot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        session.id,
                        style: AppTextStyles.badgeBold10,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: session.isCompleted
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        session.statusLabel,
                        style: AppTextStyles.captionSemibold11.copyWith(
                          fontWeight: FontWeight.w700,
                          color: session.isCompleted
                              ? AppColors.successText
                              : AppColors.warningText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                Text(session.topic, style: AppTextStyles.heading2),
                const SizedBox(height: 6.0),
                Text(
                  '${session.dateStr} • ${session.timeRange}',
                  style: AppTextStyles.subtitle11,
                ),
                const SizedBox(height: 14.0),

                // Data Siswa Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.inputSurfaceGray,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.studentName,
                              style: AppTextStyles.label,
                            ),
                            Text(
                              '${session.studentClass} • NISN: ${session.studentNisn}',
                              style: AppTextStyles.bodySmall11,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(color: AppColors.borderNeutral),
                        ),
                        child: Text(
                          session.counselingType,
                          style: AppTextStyles.badgeBold10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),

                // Catatan Hasil Konseling
                const Text('Catatan Hasil Diskusi:', style: AppTextStyles.label),
                const SizedBox(height: 4.0),
                Text(
                  session.resultNotes.isNotEmpty
                      ? session.resultNotes
                      : 'Belum ada catatan hasil evaluasi konseling.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 14.0),

                // Rencana Tindak Lanjut
                const Text('Rencana Tindak Lanjut:', style: AppTextStyles.label),
                const SizedBox(height: 4.0),
                Text(
                  session.followUpPlan.isNotEmpty
                      ? session.followUpPlan
                      : 'Belum ada rencana tindak lanjut pembinaan.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 20.0),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Catat / Edit Hasil',
                        variant: CustomButtonVariant.secondary,
                        height: 44.0,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showRecordResultSheet(session);
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: CustomButton(
                        label: session.isCompleted
                            ? 'Buka Kembali'
                            : 'Selesaikan',
                        height: 44.0,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _toggleSessionStatus(session);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredSessions;
    final activeCount = filteredList.where((s) => !s.isCompleted).length;
    final completedCount = filteredList.where((s) => s.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar Jadwal Konseling
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
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
                      const Expanded(
                        child: Text(
                          'Kelola Layanan Konseling',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.topBarTitle,
                        ),
                      ),
                      // Tombol Filter & Urutan (Interactive + Dot Active Indicator)
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

                // Expanded Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 96.0),
                    children: [
                      // Kalender Mingguan (Weekly Calendar UI)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(
                              color: AppColors.borderSoft,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowBase
                                    .withValues(alpha: 0.031),
                                offset: const Offset(0, 6),
                                blurRadius: 18.0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header Bulan & Toggle Semua Hari
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'November 2026',
                                            style: AppTextStyles.sectionHeader14,
                                          ),
                                          const SizedBox(width: 8.0),
                                          if (!_filterByDay)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 2.0,
                                                horizontal: 7.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryTint,
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                              child: const Text(
                                                'Semua Hari',
                                                style: AppTextStyles.badgeBold10,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _filterByDay = !_filterByDay;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasLightGray,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        _filterByDay
                                            ? 'Lihat Semua Hari'
                                            : 'Filter Hari Ini',
                                        style: const TextStyle(
                                          fontFamily:
                                              AppTextStyles.fontFamily,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),

                              // Deretan Hari Mingguan
                              Row(
                                children:
                                    List.generate(_weekDays.length, (index) {
                                  final item = _weekDays[index];
                                  final bool isSelected =
                                      _filterByDay && _selectedDayIndex == index;
                                  final bool hasSessionOnDay = _sessions.any(
                                      (s) => s.dayIndex == index);

                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: index < _weekDays.length - 1
                                            ? 6.0
                                            : 0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDayIndex = index;
                                            _filterByDay = true;
                                          });
                                        },
                                        child: Container(
                                          height: 61.0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 4.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryNavy
                                                : AppColors.inputSurfaceGray,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            border: isSelected
                                                ? null
                                                : Border.all(
                                                    color: AppColors.borderSoft,
                                                    width: 1.0,
                                                  ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .primaryNavy
                                                          .withValues(
                                                              alpha: 0.22),
                                                      offset:
                                                          const Offset(0, 4),
                                                      blurRadius: 10.0,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.dayName,
                                                style: TextStyle(
                                                  fontFamily: AppTextStyles
                                                      .fontFamily,
                                                  fontSize: 10.0,
                                                  height: 13.0 / 10.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.borderBlueTint
                                                      : AppColors
                                                          .textPlaceholder,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                item.dateNum,
                                                style: TextStyle(
                                                  fontFamily: AppTextStyles
                                                      .fontFamily,
                                                  fontSize: 13.0,
                                                  height: 17.0 / 13.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? AppColors.pureWhite
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Container(
                                                width: 5.0,
                                                height: 5.0,
                                                decoration: BoxDecoration(
                                                  color: hasSessionOnDay
                                                      ? (isSelected
                                                          ? AppColors.blueLight
                                                          : AppColors
                                                              .primaryNavy)
                                                      : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14.0),

                      // Bilah Pencarian Siswa & Topik
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: CustomTextField(
                          controller: _searchController,
                          hintText: 'Cari nama siswa, kelas, atau topik bimbingan...',
                          prefixIcon: Icons.search_rounded,
                          suffixIcon: _searchQuery.isNotEmpty
                              ? Icons.close_rounded
                              : null,
                          onSuffixTap: () {
                            _searchController.clear();
                          },
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Quick Filter Horizontal Chips
                      SizedBox(
                        height: 34.0,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickFilterChips.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8.0),
                          itemBuilder: (context, index) {
                            final chip = _quickFilterChips[index];
                            final isSelected = _selectedQuickFilter == chip;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedQuickFilter = chip;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 7.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(99.0),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : AppColors.borderNeutral,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  chip,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11.0,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.pureWhite
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Active Filter Tags Bar
                      if (_hasActiveFilters) ...[
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (_searchQuery.isNotEmpty)
                                        _ActiveTagChip(
                                          label: 'Cari: "$_searchQuery"',
                                          onRemove: () =>
                                              _searchController.clear(),
                                        ),
                                      if (_selectedQuickFilter != 'Semua Sesi')
                                        _ActiveTagChip(
                                          label: _selectedQuickFilter,
                                          onRemove: () => setState(() =>
                                              _selectedQuickFilter =
                                                  'Semua Sesi'),
                                        ),
                                      if (_selectedCategoryFilter != 'Semua Jenis')
                                        _ActiveTagChip(
                                          label: _selectedCategoryFilter,
                                          onRemove: () => setState(() =>
                                              _selectedCategoryFilter =
                                                  'Semua Jenis'),
                                        ),
                                      if (_selectedStatusFilter != 'Semua')
                                        _ActiveTagChip(
                                          label: _selectedStatusFilter,
                                          onRemove: () => setState(() =>
                                              _selectedStatusFilter = 'Semua'),
                                        ),
                                      if (_selectedClassFilter != 'Semua')
                                        _ActiveTagChip(
                                          label: _selectedClassFilter,
                                          onRemove: () => setState(() =>
                                              _selectedClassFilter = 'Semua'),
                                        ),
                                      if (!_filterByDay)
                                        _ActiveTagChip(
                                          label: 'Semua Hari',
                                          onRemove: () => setState(
                                              () => _filterByDay = true),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _resetAllFilters,
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14.0),

                      // Header Jadwal & Dynamic Sesi Counter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _filterByDay
                                    ? 'Jadwal ${_weekDays[_selectedDayIndex].dayName}, ${_weekDays[_selectedDayIndex].dateNum} Nov'
                                    : 'Semua Jadwal Konseling',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.sectionHeader14,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: Text(
                                '$activeCount Proses • $completedCount Selesai',
                                style: AppTextStyles.badgeBold10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // List Kartu Layanan Konseling
                      if (filteredList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_busy_rounded,
                                  size: 48.0,
                                  color: AppColors.textPlaceholder,
                                ),
                                const SizedBox(height: 12.0),
                                const Text(
                                  'Tidak ada jadwal konseling yang cocok',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: 4.0),
                                const Text(
                                  'Coba ubah tanggal atau kriteria filter Anda.',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 14.0),
                                TextButton(
                                  onPressed: _resetAllFilters,
                                  child: const Text('Reset Filter'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12.0),
                          itemBuilder: (context, index) {
                            final session = filteredList[index];
                            return _CounselingCardItem(
                              session: session,
                              onTapDetail: () => _showDetailSheet(session),
                              onRecordResult: () =>
                                  _showRecordResultSheet(session),
                              onToggleStatus: () =>
                                  _toggleSessionStatus(session),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // FAB Tambah Layanan Konseling (+) (58x58, r=18, fill=#1B3B7B)
            Positioned(
              right: 20.0,
              bottom: 28.0,
              child: GestureDetector(
                onTap: _showAddScheduleSheet,
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

/// Widget Kartu Layanan Konseling dengan Dukungan Catat Hasil & Toggle Status
class _CounselingCardItem extends StatelessWidget {
  final CounselingModel session;
  final VoidCallback onTapDetail;
  final VoidCallback onRecordResult;
  final VoidCallback onToggleStatus;

  const _CounselingCardItem({
    required this.session,
    required this.onTapDetail,
    required this.onRecordResult,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Baris: Waktu, Jenis Konseling, & Badge Status (Tanpa Dot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 13.0,
                                    color: AppColors.primaryNavy,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Flexible(
                                    child: Text(
                                      session.timeRange,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.badgeBold10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.canvasLightGray,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: Text(
                                session.counselingType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Badge Status (Tanpa Dot)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: session.isCompleted
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        session.statusLabel,
                        style: AppTextStyles.captionSemibold11.copyWith(
                          color: session.isCompleted
                              ? AppColors.successText
                              : AppColors.warningText,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Siswa & Topik Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: AppColors.inputSurfaceGray,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.borderNeutral,
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 20.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${session.studentName} • ${session.studentClass}',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13.0,
                              height: 17.0 / 13.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            session.topic,
                            style: AppTextStyles.subtitle11,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Cuplikan Hasil / Tindak Lanjut jika sudah tercatat
                if (session.resultNotes.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.canvasLightGray,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Hasil: ${session.resultNotes}',
                      style: AppTextStyles.bodySmall11,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                const SizedBox(height: 12.0),

                // Action Buttons Row (gap: 8.0)
                Row(
                  children: [
                    // Tombol 1: Catat / Edit Hasil
                    Expanded(
                      child: GestureDetector(
                        onTap: onRecordResult,
                        child: Container(
                          height: 32.0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: AppColors.borderNeutral,
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 15.0,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  'Catat / Edit Hasil',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),

                    // Tombol 2: Selesaikan / Buka Kembali (Toggle Status)
                    Expanded(
                      child: GestureDetector(
                        onTap: onToggleStatus,
                        child: Container(
                          height: 32.0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: session.isCompleted
                                ? AppColors.canvasLightGray
                                : AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(10.0),
                            border: session.isCompleted
                                ? Border.all(
                                    color: AppColors.borderNeutral,
                                    width: 1.0,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                session.isCompleted
                                    ? Icons.refresh_rounded
                                    : Icons.check_rounded,
                                size: 14.0,
                                color: session.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.pureWhite,
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  session.isCompleted
                                      ? 'Buka Kembali'
                                      : 'Selesaikan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    color: session.isCompleted
                                        ? AppColors.textSecondary
                                        : AppColors.pureWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _FilterOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : AppColors.canvasLightGray,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderNeutral,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.pureWhite : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ActiveTagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveTagChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6.0),
      padding: const EdgeInsets.only(left: 10.0, right: 6.0, top: 4.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(99.0),
        border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14.0,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
