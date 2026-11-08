import 'package:flutter/material.dart';
import '../../models/parent_consultation_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';

/// Halaman Kelola Catatan & Riwayat Konsultasi Orang Tua (`09 • Konsultasi Orang Tua (SRS-F-006)`)
/// Berdasarkan spesifikasi `09-catat-konsultasi-ortu-srs-f-006.png` dan `ebk_design.json`.
/// Mendukung:
/// 1. Melihat riwayat konsultasi & panggilan dengan orang tua / wali murid siswa.
/// 2. Menambah catatan konsultasi baru (Wali, Siswa, Waktu, Metode, Hasil Diskusi, Tindak Lanjut).
/// 3. Mengedit catatan konsultasi & memperbarui status (Dalam Proses / Selesai) tanpa dot.
/// 4. Fitur pencarian dan filter aktif (Metode, Status, Kelas, Urutan, dan Quick Chips).
class CatatKonsultasiScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CatatKonsultasiScreen({
    super.key,
    this.onBack,
  });

  @override
  State<CatatKonsultasiScreen> createState() => _CatatKonsultasiScreenState();
}

class _CatatKonsultasiScreenState extends State<CatatKonsultasiScreen> {
  late List<ParentConsultationModel> _consultations;

  // Controller Pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter Kriteria
  String _selectedQuickFilter = 'Semua Riwayat';
  String _sortBy = 'Terbaru (Waktu Pertemuan)';
  String _selectedMethodFilter = 'Semua Metode';
  String _selectedStatusFilter = 'Semua';
  String _selectedClassFilter = 'Semua';

  static const List<String> _quickFilterChips = [
    'Semua Riwayat',
    'Dalam Proses',
    'Selesai',
    'Tatap Muka',
    'Telepon / WA',
    'Home Visit',
  ];

  static const List<String> _consultationMethods = [
    'Tatap Muka di Ruang BK',
    'Panggilan Telepon / WA',
    'Home Visit / Kunjungan',
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
    _consultations = ParentConsultationModel.getInitialConsultations();
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
    return _selectedQuickFilter != 'Semua Riwayat' ||
        _sortBy != 'Terbaru (Waktu Pertemuan)' ||
        _selectedMethodFilter != 'Semua Metode' ||
        _selectedStatusFilter != 'Semua' ||
        _selectedClassFilter != 'Semua' ||
        _searchQuery.isNotEmpty;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedQuickFilter = 'Semua Riwayat';
      _sortBy = 'Terbaru (Waktu Pertemuan)';
      _selectedMethodFilter = 'Semua Metode';
      _selectedStatusFilter = 'Semua';
      _selectedClassFilter = 'Semua';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<ParentConsultationModel> get _filteredConsultations {
    final list = _consultations.where((item) {
      // Filter Pencarian Teks
      if (_searchQuery.isNotEmpty) {
        final matches = item.parentName.toLowerCase().contains(_searchQuery) ||
            item.studentName.toLowerCase().contains(_searchQuery) ||
            item.studentClass.toLowerCase().contains(_searchQuery) ||
            item.studentNisn.contains(_searchQuery) ||
            item.topic.toLowerCase().contains(_searchQuery) ||
            item.discussionSummary.toLowerCase().contains(_searchQuery) ||
            item.followUpPlan.toLowerCase().contains(_searchQuery);
        if (!matches) return false;
      }

      // Quick Chips Filter
      if (_selectedQuickFilter == 'Dalam Proses' && item.isCompleted) {
        return false;
      }
      if (_selectedQuickFilter == 'Selesai' && !item.isCompleted) {
        return false;
      }
      if (_selectedQuickFilter == 'Tatap Muka' &&
          !item.consultationMethod.contains('Tatap Muka')) {
        return false;
      }
      if (_selectedQuickFilter == 'Telepon / WA' &&
          !item.consultationMethod.contains('Telepon')) {
        return false;
      }
      if (_selectedQuickFilter == 'Home Visit' &&
          !item.consultationMethod.contains('Home Visit')) {
        return false;
      }

      // Filter Metode dari Modal Sheet
      if (_selectedMethodFilter != 'Semua Metode' &&
          item.consultationMethod != _selectedMethodFilter) {
        return false;
      }

      // Filter Status dari Modal Sheet
      if (_selectedStatusFilter == 'Dalam Proses' && item.isCompleted) {
        return false;
      }
      if (_selectedStatusFilter == 'Selesai' && !item.isCompleted) {
        return false;
      }

      // Filter Tingkat Kelas
      if (_selectedClassFilter == 'Kelas VII' &&
          !item.studentClass.contains('VII-')) {
        return false;
      }
      if (_selectedClassFilter == 'Kelas VIII' &&
          !item.studentClass.contains('VIII-')) {
        return false;
      }
      if (_selectedClassFilter == 'Kelas IX' &&
          !item.studentClass.contains('IX-')) {
        return false;
      }

      return true;
    }).toList();

    // Pengurutan (Sorting)
    if (_sortBy == 'Terbaru (Waktu Pertemuan)') {
      // Mock list urutan awal sudah kronologis terbaru
    } else if (_sortBy == 'Terlama') {
      list.sort((a, b) => a.id.compareTo(b.id));
    } else if (_sortBy == 'Nama Wali Murid (A – Z)') {
      list.sort((a, b) => a.parentName.compareTo(b.parentName));
    } else if (_sortBy == 'Nama Siswa (A – Z)') {
      list.sort((a, b) => a.studentName.compareTo(b.studentName));
    }

    return list;
  }

  // Toggle Cepat Status Konsultasi
  void _toggleStatus(ParentConsultationModel item) {
    setState(() {
      final index = _consultations.indexWhere((c) => c.id == item.id);
      if (index != -1) {
        final newStatus = !_consultations[index].isCompleted;
        _consultations[index] =
            _consultations[index].copyWith(isCompleted: newStatus);

        ToastNotification.show(
          context,
          message: newStatus
              ? 'Konsultasi ${item.id} (${item.parentName}) diselesaikan.'
              : 'Status konsultasi ${item.id} dibuka kembali (Dalam Proses).',
          type: ToastType.success,
        );
      }
    });
  }

  // Modal Bottom Sheet: Filter & Urutkan
  void _showFilterSortSheet() {
    String tempSort = _sortBy;
    String tempMethod = _selectedMethodFilter;
    String tempStatus = _selectedStatusFilter;
    String tempClass = _selectedClassFilter;

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
                          'Filter & Urutkan Konsultasi',
                          style: AppTextStyles.heading2,
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSort = 'Terbaru (Waktu Pertemuan)';
                              tempMethod = 'Semua Metode';
                              tempStatus = 'Semua';
                              tempClass = 'Semua';
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

                    // Urutkan Berdasarkan
                    const Text('Urutkan Berdasarkan', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        'Terbaru (Waktu Pertemuan)',
                        'Terlama',
                        'Nama Wali Murid (A – Z)',
                        'Nama Siswa (A – Z)',
                      ].map((sortOption) {
                        return _FilterChipWidget(
                          label: sortOption,
                          isSelected: tempSort == sortOption,
                          onTap: () =>
                              setModalState(() => tempSort = sortOption),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Filter Metode Komunikasi
                    const Text('Metode / Media Konsultasi',
                        style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        'Semua Metode',
                        'Tatap Muka di Ruang BK',
                        'Panggilan Telepon / WA',
                        'Home Visit / Kunjungan',
                      ].map((method) {
                        return _FilterChipWidget(
                          label: method,
                          isSelected: tempMethod == method,
                          onTap: () =>
                              setModalState(() => tempMethod = method),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Filter Status Konsultasi
                    const Text('Status Konsultasi', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChipWidget(
                            label: 'Semua',
                            isSelected: tempStatus == 'Semua',
                            onTap: () =>
                                setModalState(() => tempStatus = 'Semua'),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: _FilterChipWidget(
                            label: 'Dalam Proses',
                            isSelected: tempStatus == 'Dalam Proses',
                            onTap: () => setModalState(
                                () => tempStatus = 'Dalam Proses'),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: _FilterChipWidget(
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
                          child: _FilterChipWidget(
                            label: 'Semua',
                            isSelected: tempClass == 'Semua',
                            onTap: () =>
                                setModalState(() => tempClass = 'Semua'),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: _FilterChipWidget(
                            label: 'Kelas VII',
                            isSelected: tempClass == 'Kelas VII',
                            onTap: () =>
                                setModalState(() => tempClass = 'Kelas VII'),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: _FilterChipWidget(
                            label: 'Kelas VIII',
                            isSelected: tempClass == 'Kelas VIII',
                            onTap: () =>
                                setModalState(() => tempClass = 'Kelas VIII'),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: _FilterChipWidget(
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
                          _selectedMethodFilter = tempMethod;
                          _selectedStatusFilter = tempStatus;
                          _selectedClassFilter = tempClass;
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

  // Modal Bottom Sheet: Form Tambah / Edit Catatan Konsultasi Orang Tua
  void _showFormSheet({ParentConsultationModel? editItem}) {
    final bool isEdit = editItem != null;
    final waliCtrl =
        TextEditingController(text: isEdit ? editItem.parentName : '');
    final dateCtrl = TextEditingController(
      text: isEdit ? editItem.dateTimeText : 'Selasa, 10 Nov 2026 • 10:00 WIB',
    );
    final topicCtrl =
        TextEditingController(text: isEdit ? editItem.topic : '');
    final summaryCtrl =
        TextEditingController(text: isEdit ? editItem.discussionSummary : '');
    final followUpCtrl =
        TextEditingController(text: isEdit ? editItem.followUpPlan : '');

    Map<String, String> selectedStudent = _availableStudents.first;
    if (isEdit) {
      final found = _availableStudents.firstWhere(
        (s) => s['name'] == editItem.studentName,
        orElse: () => _availableStudents.first,
      );
      selectedStudent = found;
    }

    String selectedMethod =
        isEdit ? editItem.consultationMethod : _consultationMethods.first;
    bool isCompleted = isEdit ? editItem.isCompleted : false;

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

                    Text(
                      isEdit
                          ? 'Edit Catatan Konsultasi (${editItem.id})'
                          : 'Catat Konsultasi Orang Tua',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 14.0),

                    // 1. Nama Wali Murid
                    const Text('Nama Wali Murid', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: waliCtrl,
                      hintText: 'Contoh: Bapak Hendra Pratama',
                      prefixIcon: Icons.people_outline_rounded,
                    ),
                    const SizedBox(height: 14.0),

                    // 2. Pilih Siswa
                    const Text('Siswa Terkait', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
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

                    // 3. Tanggal & Waktu Pertemuan
                    const Text('Waktu Pertemuan / Panggilan',
                        style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: dateCtrl,
                      hintText: 'Contoh: Selasa, 10 Nov 2026 • 10:00 WIB',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Metode Konsultasi
                    const Text('Metode / Media Konsultasi',
                        style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _consultationMethods.map((m) {
                        return _FilterChipWidget(
                          label: m,
                          isSelected: selectedMethod == m,
                          onTap: () => setModalState(() => selectedMethod = m),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14.0),

                    // 5. Topik Konsultasi
                    const Text('Topik Pembahasan', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: topicCtrl,
                      hintText:
                          'Contoh: Evaluasi Kedisiplinan & Jam Istirahat Siswa',
                      prefixIcon: Icons.forum_outlined,
                    ),
                    const SizedBox(height: 14.0),

                    // 6. Hasil Diskusi / Konsultasi
                    const Text('Hasil Diskusi / Konsultasi',
                        style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
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
                        controller: summaryCtrl,
                        maxLines: 3,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText:
                              'Tuliskan pokok pembahasan serta tanggapan orang tua/wali selama pertemuan...',
                          hintStyle: AppTextStyles.body,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 7. Tindak Lanjut
                    const Text('Rencana Tindak Lanjut',
                        style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
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
                              'Tuliskan kesepakatan rencana pembinaan bersama di rumah dan sekolah...',
                          hintStyle: AppTextStyles.body,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 8. Status Konsultasi (Tanpa Dot)
                    const Text('Status Konsultasi', style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => isCompleted = false),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: !isCompleted
                                    ? AppColors.warningBg
                                    : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: !isCompleted
                                      ? AppColors.warningAccent
                                      : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Dalam Proses',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: !isCompleted
                                      ? AppColors.warningText
                                      : AppColors.textSecondary,
                                  fontWeight: !isCompleted
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
                                setModalState(() => isCompleted = true),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? AppColors.successBg
                                    : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isCompleted
                                      ? AppColors.successBorder
                                      : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Selesai Konsultasi',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: isCompleted
                                      ? AppColors.successText
                                      : AppColors.textSecondary,
                                  fontWeight: isCompleted
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
                      label: isEdit ? 'Simpan Perubahan' : 'Simpan Catatan',
                      height: 50.0,
                      onPressed: () {
                        if (waliCtrl.text.trim().isEmpty ||
                            topicCtrl.text.trim().isEmpty) {
                          ToastNotification.show(
                            context,
                            message:
                                'Peringatan: Mohon lengkapi nama wali dan topik pembahasan.',
                            type: ToastType.error,
                          );
                          return;
                        }

                        setState(() {
                          if (isEdit) {
                            final idx = _consultations
                                .indexWhere((c) => c.id == editItem.id);
                            if (idx != -1) {
                              _consultations[idx] =
                                  _consultations[idx].copyWith(
                                parentName: waliCtrl.text.trim(),
                                studentName: selectedStudent['name']!,
                                studentClass: selectedStudent['class']!,
                                studentNisn: selectedStudent['nisn']!,
                                dateTimeText: dateCtrl.text.trim(),
                                consultationMethod: selectedMethod,
                                topic: topicCtrl.text.trim(),
                                discussionSummary: summaryCtrl.text.trim(),
                                followUpPlan: followUpCtrl.text.trim(),
                                isCompleted: isCompleted,
                              );
                            }
                          } else {
                            final newId = 'KOP-0${_consultations.length + 1}';
                            final newItem = ParentConsultationModel(
                              id: newId,
                              parentName: waliCtrl.text.trim(),
                              studentName: selectedStudent['name']!,
                              studentClass: selectedStudent['class']!,
                              studentNisn: selectedStudent['nisn']!,
                              dateTimeText: dateCtrl.text.trim(),
                              consultationMethod: selectedMethod,
                              topic: topicCtrl.text.trim(),
                              discussionSummary: summaryCtrl.text.trim(),
                              followUpPlan: followUpCtrl.text.trim(),
                              isCompleted: isCompleted,
                            );
                            _consultations.insert(0, newItem);
                          }
                        });

                        Navigator.pop(ctx);
                        ToastNotification.show(
                          context,
                          message: isEdit
                              ? 'Catatan konsultasi ${editItem.id} berhasil diperbarui.'
                              : 'Berhasil: Catatan konsultasi orang tua baru telah disimpan.',
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

  // Modal Sheet: Detail Lengkap Konsultasi Orang Tua
  void _showDetailSheet(ParentConsultationModel item) {
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

                // ID, Metode & Status (Tanpa Dot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                            item.id,
                            style: AppTextStyles.badgeBold10,
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
                          child: Text(
                            item.consultationMethod,
                            style: AppTextStyles.badgeSemibold10,
                          ),
                        ),
                      ],
                    ),
                    // Badge Status (Tanpa Dot)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: AppTextStyles.captionSemibold11.copyWith(
                          fontWeight: FontWeight.w700,
                          color: item.isCompleted
                              ? AppColors.successText
                              : AppColors.warningText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),

                // Topik Utama
                Text(item.topic, style: AppTextStyles.heading2),
                const SizedBox(height: 4.0),
                Text(item.dateTimeText, style: AppTextStyles.subtitle11),
                const SizedBox(height: 14.0),

                // Info Orang Tua & Siswa
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
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.family_restroom_rounded,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.parentName, style: AppTextStyles.label),
                            Text(
                              'Wali dari: ${item.studentName} • ${item.studentClass} (${item.studentNisn})',
                              style: AppTextStyles.bodySmall11,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),

                // Hasil Diskusi
                const Text('Hasil Diskusi / Konsultasi:',
                    style: AppTextStyles.label),
                const SizedBox(height: 4.0),
                Text(
                  item.discussionSummary.isNotEmpty
                      ? item.discussionSummary
                      : 'Belum ada catatan ringkasan hasil diskusi.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 14.0),

                // Tindak Lanjut
                const Text('Rencana Tindak Lanjut Bersama:',
                    style: AppTextStyles.label),
                const SizedBox(height: 4.0),
                Text(
                  item.followUpPlan.isNotEmpty
                      ? item.followUpPlan
                      : 'Belum ada rencana tindak lanjut tercatat.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 20.0),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Edit Catatan',
                        variant: CustomButtonVariant.secondary,
                        height: 44.0,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showFormSheet(editItem: item);
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: CustomButton(
                        label: item.isCompleted ? 'Buka Kembali' : 'Selesaikan',
                        height: 44.0,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _toggleStatus(item);
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
    final filteredList = _filteredConsultations;
    final activeCount = filteredList.where((c) => !c.isCompleted).length;
    final completedCount = filteredList.where((c) => c.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar Kelola Konsultasi Orang Tua
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
                          'Konsultasi Orang Tua',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.topBarTitle,
                        ),
                      ),
                      // Tombol Filter Interaktif dengan Active Indicator
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
                      // Bilah Pencarian Siswa & Wali
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: CustomTextField(
                          controller: _searchController,
                          hintText:
                              'Cari nama wali, siswa, NISN, atau topik...',
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
                                      if (_selectedQuickFilter !=
                                          'Semua Riwayat')
                                        _ActiveTagChip(
                                          label: _selectedQuickFilter,
                                          onRemove: () => setState(() =>
                                              _selectedQuickFilter =
                                                  'Semua Riwayat'),
                                        ),
                                      if (_selectedMethodFilter !=
                                          'Semua Metode')
                                        _ActiveTagChip(
                                          label: _selectedMethodFilter,
                                          onRemove: () => setState(() =>
                                              _selectedMethodFilter =
                                                  'Semua Metode'),
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

                      // Header Riwayat & Dynamic Counter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                'Riwayat Panggilan & Konsultasi',
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

                      // Daftar Kartu Konsultasi
                      if (filteredList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.contact_phone_outlined,
                                  size: 48.0,
                                  color: AppColors.textPlaceholder,
                                ),
                                const SizedBox(height: 12.0),
                                const Text(
                                  'Tidak ada catatan konsultasi orang tua',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: 4.0),
                                const Text(
                                  'Coba ubah kata kunci pencarian atau kriteria filter Anda.',
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
                            final item = filteredList[index];
                            return _ConsultationCardItem(
                              item: item,
                              onTapDetail: () => _showDetailSheet(item),
                              onEdit: () => _showFormSheet(editItem: item),
                              onToggleStatus: () => _toggleStatus(item),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // FAB Tambah Catatan Konsultasi Orang Tua (+) (58x58, r=18, fill=#1B3B7B)
            Positioned(
              right: 20.0,
              bottom: 28.0,
              child: GestureDetector(
                onTap: () => _showFormSheet(),
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

/// Widget Kartu Riwayat Konsultasi Orang Tua
class _ConsultationCardItem extends StatelessWidget {
  final ParentConsultationModel item;
  final VoidCallback onTapDetail;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const _ConsultationCardItem({
    required this.item,
    required this.onTapDetail,
    required this.onEdit,
    required this.onToggleStatus,
  });

  IconData get _methodIcon {
    if (item.consultationMethod.contains('Telepon')) {
      return Icons.phone_in_talk_rounded;
    } else if (item.consultationMethod.contains('Home Visit')) {
      return Icons.home_work_rounded;
    }
    return Icons.meeting_room_rounded;
  }

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
                // Header Baris ID, Metode, & Status (Tanpa Dot)
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
                              item.id,
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
                                color: AppColors.canvasLightGray,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _methodIcon,
                                    size: 12.0,
                                    color: AppColors.primaryNavy,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Flexible(
                                    child: Text(
                                      item.consultationMethod,
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
                                ],
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
                        color: item.isCompleted
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: AppTextStyles.captionSemibold11.copyWith(
                          color: item.isCompleted
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

                // Topik Konsultasi
                Text(
                  item.topic,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 14.0,
                    color: AppColors.primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),

                // Wali & Siswa Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38.0,
                      height: 38.0,
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
                        Icons.family_restroom_rounded,
                        size: 20.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.parentName,
                            style: AppTextStyles.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Wali dari: ${item.studentName} • ${item.studentClass}',
                            style: AppTextStyles.bodySmall11,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Ringkasan Hasil Diskusi
                if (item.discussionSummary.isNotEmpty) ...[
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
                      'Hasil: ${item.discussionSummary}',
                      style: AppTextStyles.bodySmall11,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                const SizedBox(height: 8.0),
                // Waktu Pelaksanaan
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13.0,
                      color: AppColors.textPlaceholder,
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        item.dateTimeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12.0),

                // Action Buttons Row (gap: 8.0)
                Row(
                  children: [
                    // Tombol 1: Edit Catatan
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
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
                              Text(
                                'Edit Catatan',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryNavy,
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
                            color: item.isCompleted
                                ? AppColors.canvasLightGray
                                : AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(10.0),
                            border: item.isCompleted
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
                                item.isCompleted
                                    ? Icons.refresh_rounded
                                    : Icons.check_rounded,
                                size: 14.0,
                                color: item.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.pureWhite,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                item.isCompleted
                                    ? 'Buka Kembali'
                                    : 'Selesaikan',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: item.isCompleted
                                      ? AppColors.textSecondary
                                      : AppColors.pureWhite,
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

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipWidget({
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
      padding:
          const EdgeInsets.only(left: 10.0, right: 6.0, top: 4.0, bottom: 4.0),
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
