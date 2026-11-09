import 'package:flutter/material.dart';
import '../../core/app_exception.dart';
import '../../models/case_model.dart';
import '../../models/student_model.dart';
import '../../repositories/case_repository.dart';
import '../../repositories/student_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/student_card.dart';
import '../../widgets/toast_notification.dart';
import '../dashboard/profil_view.dart';
import '../states/delete_dialog.dart';

export '../../models/student_model.dart';

enum StudentSortOption {
  nameAsc('Nama (A – Z)'),
  nameDesc('Nama (Z – A)'),
  nisnAsc('NISN (Terkecil)'),
  classAsc('Tingkat Kelas (VII – IX)');

  final String label;
  const StudentSortOption(this.label);
}

/// Halaman Kelola Data Siswa (`06 • Data Siswa (SRS-F-003)`)
/// Mendukung fitur CRUD lengkap (melihat detail, menambah, mengedit, menghapus)
/// dan Filter & Urutkan interaktif (kelas spesifik, jenis kelamin, dan urutan sorting)
/// sesuai `06-data-siswa-srs-f-003.png` dan `ebk_design.json`.
/// Untuk role Kepala Sekolah, menu dibatasi hanya untuk melihat (read-only).
class DataSiswaScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<CaseRecordModel?>? onOpenDetail;
  final bool isReadOnly;
  final ProfilRole? role;

  const DataSiswaScreen({
    super.key,
    this.onBack,
    this.onOpenDetail,
    this.isReadOnly = false,
    this.role,
  });

  @override
  State<DataSiswaScreen> createState() => _DataSiswaScreenState();
}

class _DataSiswaScreenState extends State<DataSiswaScreen> {
  bool get _isReadOnly {
    if (widget.isReadOnly || widget.role == ProfilRole.kepalaSekolah) {
      return true;
    }
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic>) {
      if (routeArgs['isReadOnly'] == true ||
          routeArgs['role'] == ProfilRole.kepalaSekolah ||
          routeArgs['role'] == 'kepsek' ||
          routeArgs['role'] == 'kepala_sekolah') {
        return true;
      }
    } else if (routeArgs is ProfilRole &&
        routeArgs == ProfilRole.kepalaSekolah) {
      return true;
    }
    return false;
  }

  final TextEditingController _searchController = TextEditingController();
  String _selectedGradeFilter = 'Semua';
  String? _selectedSpecificClass;
  String _selectedGenderFilter = 'Semua';
  StudentSortOption _selectedSortOption = StudentSortOption.nameAsc;
  String _searchQuery = '';

  static const List<String> _gradeFilters = [
    'Semua',
    'Kelas VII',
    'Kelas VIII',
    'Kelas IX',
  ];

  static const List<String> _classOptions = [
    'Kelas VII-A',
    'Kelas VII-B',
    'Kelas VII-C',
    'Kelas VIII-A',
    'Kelas VIII-B',
    'Kelas VIII-C',
    'Kelas IX-A',
    'Kelas IX-B',
    'Kelas IX-C',
  ];

  List<StudentDataModel> _students = List.from(StudentDataModel.defaultStudents);

  @override
  void initState() {
    super.initState();
    _loadStudentsFromPocketBase();
  }

  Future<void> _loadStudentsFromPocketBase() async {
    try {
      final list = await StudentRepository.instance.getStudents();
      if (mounted) {
        setState(() {
          _students = list;
        });
      }
    } catch (_) {}
  }

  static String _deriveGradeLevel(String className) {
    if (className.startsWith('Kelas IX')) return 'Kelas IX';
    if (className.startsWith('Kelas VIII')) return 'Kelas VIII';
    return 'Kelas VII';
  }

  bool get _hasActiveFilters =>
      _selectedSpecificClass != null ||
      _selectedGenderFilter != 'Semua' ||
      _selectedSortOption != StudentSortOption.nameAsc;

  List<StudentDataModel> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();
    final list = _students.where((student) {
      final matchesGrade = _selectedGradeFilter == 'Semua' ||
          student.gradeLevel == _selectedGradeFilter;
      final matchesSpecificClass = _selectedSpecificClass == null ||
          student.className == _selectedSpecificClass;
      final matchesGender = _selectedGenderFilter == 'Semua' ||
          student.gender == _selectedGenderFilter;
      final matchesSearch = query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.nisn.toLowerCase().contains(query) ||
          student.nis.toLowerCase().contains(query) ||
          student.guardianName.toLowerCase().contains(query) ||
          student.guardianPhone.toLowerCase().contains(query);
      return matchesGrade &&
          matchesSpecificClass &&
          matchesGender &&
          matchesSearch;
    }).toList();

    switch (_selectedSortOption) {
      case StudentSortOption.nameAsc:
        list.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case StudentSortOption.nameDesc:
        list.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case StudentSortOption.nisnAsc:
        list.sort((a, b) => a.nisn.compareTo(b.nisn));
        break;
      case StudentSortOption.classAsc:
        list.sort((a, b) => a.className.compareTo(b.className));
        break;
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedSpecificClass = null;
      _selectedGenderFilter = 'Semua';
      _selectedSortOption = StudentSortOption.nameAsc;
    });
    ToastNotification.show(
      context,
      message: 'Filter telah dikembalikan ke default.',
      type: ToastType.success,
    );
  }

  void _showFilterSortSheet() {
    String? tempClass = _selectedSpecificClass;
    String tempGender = _selectedGenderFilter;
    StudentSortOption tempSort = _selectedSortOption;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalBackdrop,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool hasChanges = tempClass != null ||
                tempGender != 'Semua' ||
                tempSort != StudentSortOption.nameAsc;

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
                    // Header Filter & Urutkan
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
                              'Filter & Urutkan',
                              style: AppTextStyles.topBarTitle,
                            ),
                          ],
                        ),
                        if (hasChanges)
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempClass = null;
                                tempGender = 'Semua';
                                tempSort = StudentSortOption.nameAsc;
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
                              children: StudentSortOption.values.map((opt) {
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

                            // 2. Filter Kelas Spesifik
                            const Text(
                              'Pilih Kelas Spesifik',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempClass = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 14.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tempClass == null
                                          ? AppColors.primaryNavy
                                          : AppColors.inputSurfaceGray,
                                      borderRadius:
                                          BorderRadius.circular(99.0),
                                      border: Border.all(
                                        color: tempClass == null
                                            ? AppColors.primaryNavy
                                            : AppColors.borderNeutral,
                                      ),
                                    ),
                                    child: Text(
                                      'Semua Kelas',
                                      style: AppTextStyles.metaSemibold12
                                          .copyWith(
                                        color: tempClass == null
                                            ? AppColors.pureWhite
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                ..._classOptions.map((kelas) {
                                  final isSelected = tempClass == kelas;
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        tempClass = isSelected ? null : kelas;
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
                                        kelas,
                                        style: AppTextStyles.metaSemibold12
                                            .copyWith(
                                          color: isSelected
                                              ? AppColors.pureWhite
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 16.0),

                            // 3. Filter Jenis Kelamin
                            const Text(
                              'Jenis Kelamin',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                'Semua',
                                'Laki-laki',
                                'Perempuan',
                              ].map((gender) {
                                final isSelected = tempGender == gender;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          tempGender = gender;
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
                                          gender,
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
                          _selectedSpecificClass = tempClass;
                          _selectedGenderFilter = tempGender;
                          _selectedSortOption = tempSort;
                          if (tempClass != null) {
                            _selectedGradeFilter =
                                _deriveGradeLevel(tempClass!);
                          }
                        });
                        Navigator.of(sheetContext).pop();
                        ToastNotification.show(
                          this.context,
                          message:
                              'Filter diterapkan: ${_filteredStudents.length} siswa ditemukan.',
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

  Future<void> _confirmDeleteStudent(StudentDataModel student) async {
    if (_isReadOnly) {
      ToastNotification.show(
        context,
        message:
            'Akses ditolak: Kepala Sekolah hanya memiliki izin melihat data siswa.',
        type: ToastType.error,
      );
      return;
    }
    final confirmed = await DeleteDialog.show(
      context,
      title: 'Hapus Data Siswa?',
      message:
          'Apakah Anda yakin ingin menghapus data ${student.name} (NISN: ${student.nisn}) beserta riwayat kasusnya secara permanen?',
    );
    if (confirmed == true && mounted) {
      try {
        if (student.id.isNotEmpty && !student.id.startsWith('std-')) {
          await StudentRepository.instance.deleteStudent(student.id);
        }
      } on AppException catch (e) {
        if (!mounted) return;
        ToastNotification.show(
          context,
          message: e.message,
          type: ToastType.error,
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _students.remove(student);
      });
      ToastNotification.show(
        context,
        message: 'Berhasil: Data siswa ${student.name} telah dihapus.',
        type: ToastType.success,
      );
    }
  }

  void _showStudentDetailSheet(StudentDataModel student) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalBackdrop,
      builder: (sheetContext) {
        return Container(
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
                const SizedBox(height: 16.0),
                // Header Detail Siswa
                Row(
                  children: [
                    Container(
                      width: 52.0,
                      height: 52.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.borderBlueAccent),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 26.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: AppTextStyles.topBarTitle,
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
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
                                  student.className,
                                  style: AppTextStyles.badgeBold10,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                student.gender,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Informasi Lengkap Siswa & Kontak Wali
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.inputSurfaceGray,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: AppColors.borderNeutral),
                  ),
                  child: Column(
                    children: [
                      _DetailInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'NIS / NISN',
                        value: '${student.nis} / ${student.nisn}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          height: 1.0,
                          color: AppColors.borderNeutral,
                        ),
                      ),
                      _DetailInfoRow(
                        icon: Icons.school_outlined,
                        label: 'Kelas & Tahun Pelajaran',
                        value: '${student.className} • TP 2026/2027',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          height: 1.0,
                          color: AppColors.borderNeutral,
                        ),
                      ),
                      _DetailInfoRow(
                        icon: Icons.family_restroom_outlined,
                        label: 'Nama Orang Tua / Wali',
                        value:
                            '${student.guardianName} (${student.guardianRelation})',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          height: 1.0,
                          color: AppColors.borderNeutral,
                        ),
                      ),
                      _DetailInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Kontak Wali (HP / WhatsApp)',
                        value: student.guardianPhone,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          height: 1.0,
                          color: AppColors.borderNeutral,
                        ),
                      ),
                      _DetailInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat Tempat Tinggal',
                        value: student.address,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),
                // Pintasan Lihat Riwayat Kasus / Catat Kasus
                GestureDetector(
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    CaseRecordModel matchedCase =
                        CaseRecordModel.defaultCases.firstWhere(
                      (c) =>
                          c.studentNisn == student.nisn ||
                          c.studentName == student.name,
                      orElse: () => CaseRecordModel.defaultCases.first,
                    );
                    try {
                      final cases = await CaseRepository.instance.getCases();
                      if (cases.isNotEmpty) {
                        matchedCase = cases.firstWhere(
                          (c) =>
                              c.studentNisn == student.nisn ||
                              c.studentName == student.name,
                          orElse: () => cases.first,
                        );
                      }
                    } catch (_) {}
                    if (!mounted) return;
                    if (widget.onOpenDetail != null) {
                      widget.onOpenDetail!(matchedCase);
                    } else {
                      Navigator.pushNamed(
                        context,
                        '/detail-kasus',
                        arguments: {
                          'caseData': matchedCase,
                          'role': widget.role ??
                              (_isReadOnly
                                  ? ProfilRole.kepalaSekolah
                                  : ProfilRole.guruBk),
                          'isReadOnly': _isReadOnly,
                        },
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: AppColors.borderBlueAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 18.0,
                          color: AppColors.primaryNavy,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Lihat Riwayat Kasus & Catatan BK Siswa',
                            style: AppTextStyles.metaSemibold12.copyWith(
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18.0,
                          color: AppColors.primaryNavy,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Tombol Aksi: Edit & Hapus (Guru BK) atau Tutup (Kepala Sekolah)
                if (!_isReadOnly)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton.secondary(
                          label: 'Edit Data',
                          height: 48.0,
                          borderRadius: 12.0,
                          leadingIcon: Icons.edit_outlined,
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _showStudentFormSheet(existingStudent: student);
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: CustomButton(
                          label: 'Hapus Siswa',
                          variant: CustomButtonVariant.danger,
                          height: 48.0,
                          borderRadius: 12.0,
                          leadingIcon: Icons.delete_outline_rounded,
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _confirmDeleteStudent(student);
                          },
                        ),
                      ),
                    ],
                  )
                else
                  CustomButton.secondary(
                    label: 'Tutup Detail Siswa',
                    height: 48.0,
                    borderRadius: 12.0,
                    leadingIcon: Icons.close_rounded,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStudentFormSheet({StudentDataModel? existingStudent}) {
    if (_isReadOnly) {
      ToastNotification.show(
        context,
        message:
            'Akses ditolak: Kepala Sekolah hanya memiliki izin melihat data siswa.',
        type: ToastType.error,
      );
      return;
    }
    final bool isEditing = existingStudent != null;
    final nameController = TextEditingController(
      text: existingStudent?.name ?? '',
    );
    final nisController = TextEditingController(
      text: existingStudent?.nis ?? '',
    );
    final nisnController = TextEditingController(
      text: existingStudent?.nisn ?? '',
    );
    final guardianNameController = TextEditingController(
      text: existingStudent?.guardianName ?? '',
    );
    final guardianRelationController = TextEditingController(
      text: existingStudent?.guardianRelation ?? 'Orang Tua / Wali',
    );
    final guardianPhoneController = TextEditingController(
      text: existingStudent?.guardianPhone ?? '',
    );
    final addressController = TextEditingController(
      text: existingStudent?.address ?? '',
    );

    String selectedClass = existingStudent?.className ?? _classOptions.first;
    String selectedGender = existingStudent?.gender ?? 'Laki-laki';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalBackdrop,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
                decoration: const BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.0),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle Bar
                      Container(
                        width: 44.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.borderMuted,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      // Header Form
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing
                                ? 'Edit Data Siswa'
                                : 'Tambah Data Siswa Baru',
                            style: AppTextStyles.topBarTitle,
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderNeutral),
                      const SizedBox(height: 8.0),
                      // Isi Form Scrollable
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                label: 'Nama Lengkap Siswa *',
                                hintText: 'Contoh: Rizky Pratama',
                                controller: nameController,
                                prefixIcon: Icons.person_outline_rounded,
                                containerHeight: 48.0,
                                borderRadius: 12.0,
                              ),
                              const SizedBox(height: 14.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'NIS *',
                                      hintText: 'Contoh: 242509042',
                                      controller: nisController,
                                      keyboardType: TextInputType.number,
                                      containerHeight: 48.0,
                                      borderRadius: 12.0,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'NISN *',
                                      hintText: '10 digit NISN',
                                      controller: nisnController,
                                      keyboardType: TextInputType.number,
                                      containerHeight: 48.0,
                                      borderRadius: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14.0),
                              // Pilihan Kelas
                              Row(
                                children: [
                                  const Text(
                                    'Kelas',
                                    style: AppTextStyles.label,
                                  ),
                                  Text(
                                    ' *',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.errorPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                height: 48.0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputSurfaceGray,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: AppColors.borderNeutral,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedClass,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textMuted,
                                    ),
                                    style: AppTextStyles.label,
                                    items: _classOptions
                                        .map(
                                          (kelas) => DropdownMenuItem<String>(
                                            value: kelas,
                                            child: Text(kelas),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedClass = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14.0),
                              // Jenis Kelamin Segmented
                              const Text(
                                'Jenis Kelamin',
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: 6.0),
                              Row(
                                children: ['Laki-laki', 'Perempuan'].map((g) {
                                  final isSelected = selectedGender == g;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: g == 'Laki-laki' ? 8.0 : 0.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            selectedGender = g;
                                          });
                                        },
                                        child: Container(
                                          height: 42.0,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryNavy
                                                : AppColors.inputSurfaceGray,
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryNavy
                                                  : AppColors.borderNeutral,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            g,
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
                              const SizedBox(height: 14.0),
                              CustomTextField(
                                label: 'Nama Orang Tua / Wali *',
                                hintText: 'Masukkan nama ayah/ibu/wali',
                                controller: guardianNameController,
                                prefixIcon: Icons.family_restroom_outlined,
                                containerHeight: 48.0,
                                borderRadius: 12.0,
                              ),
                              const SizedBox(height: 14.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Hubungan Wali',
                                      hintText: 'Ayah / Ibu / Wali',
                                      controller: guardianRelationController,
                                      containerHeight: 48.0,
                                      borderRadius: 12.0,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Kontak Wali (HP/WA) *',
                                      hintText: '0812-xxxx-xxxx',
                                      controller: guardianPhoneController,
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icons.phone_outlined,
                                      containerHeight: 48.0,
                                      borderRadius: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14.0),
                              CustomTextField(
                                label: 'Alamat Lengkap',
                                hintText: 'Masukkan alamat tempat tinggal siswa',
                                controller: addressController,
                                maxLines: 2,
                                containerHeight: 72.0,
                                borderRadius: 12.0,
                              ),
                              const SizedBox(height: 18.0),
                              CustomButton.primary(
                                label: isEditing
                                    ? 'Simpan Perubahan'
                                    : 'Tambah Siswa',
                                leadingIcon: Icons.check_circle_outline_rounded,
                                onPressed: () async {
                                  final name = nameController.text.trim();
                                  final nis = nisController.text.trim();
                                  final nisn = nisnController.text.trim();
                                  final guardianName =
                                      guardianNameController.text.trim();
                                  final guardianPhone =
                                      guardianPhoneController.text.trim();

                                  if (name.isEmpty ||
                                      nisn.isEmpty ||
                                      guardianName.isEmpty ||
                                      guardianPhone.isEmpty) {
                                    ToastNotification.show(
                                      this.context,
                                      message:
                                          'Mohon lengkapi Nama, NISN, Nama Wali, dan Kontak Wali.',
                                      type: ToastType.error,
                                    );
                                    return;
                                  }

                                  StudentDataModel updated = StudentDataModel(
                                    id: existingStudent?.id ?? '',
                                    name: name,
                                    nis: nis.isEmpty ? '-' : nis,
                                    nisn: nisn,
                                    className: selectedClass,
                                    gradeLevel:
                                        _deriveGradeLevel(selectedClass),
                                    gender: selectedGender,
                                    guardianId:
                                        existingStudent?.guardianId ?? '',
                                    guardianName: guardianName,
                                    guardianRelation: guardianRelationController
                                            .text
                                            .trim()
                                            .isEmpty
                                        ? 'Orang Tua / Wali'
                                        : guardianRelationController.text
                                            .trim(),
                                    guardianPhone: guardianPhone,
                                    address: addressController.text
                                            .trim()
                                            .isEmpty
                                        ? 'Kec. Pabuaran, Kab. Subang'
                                        : addressController.text.trim(),
                                    totalPoints:
                                        existingStudent?.totalPoints ?? 0,
                                  );

                                  try {
                                    if (isEditing &&
                                        existingStudent.id.isNotEmpty &&
                                        !existingStudent.id
                                            .startsWith('std-')) {
                                      updated = await StudentRepository.instance
                                          .updateStudent(
                                        existingStudent.id,
                                        updated,
                                      );
                                    } else {
                                      updated = await StudentRepository.instance
                                          .createStudent(updated);
                                    }
                                  } catch (_) {}

                                  if (!mounted) return;
                                  setState(() {
                                    if (isEditing) {
                                      final idx =
                                          _students.indexOf(existingStudent);
                                      if (idx != -1) {
                                        _students[idx] = updated;
                                      }
                                    } else {
                                      _students.insert(0, updated);
                                    }
                                  });

                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                  ToastNotification.show(
                                    this.context,
                                    message: isEditing
                                        ? 'Berhasil: Data siswa $name telah diperbarui.'
                                        : 'Berhasil: Siswa $name telah ditambahkan.',
                                    type: ToastType.success,
                                  );
                                },
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

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;

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
                  // Top Bar Data Siswa (height: 44.0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tombol Back (40x40, r=12)
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
                            'Data Siswa',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.topBarTitle,
                          ),
                        ),
                        // Filter Sort Icon Button (40x40, r=12)
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
                  const SizedBox(height: 14.0),
                  // Search Bar Siswa (height: 44.0, r=14, pad=[12, 14], gap=10)
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
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Cari nama siswa atau NISN...',
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
                  const SizedBox(height: 14.0),
                  // Chip Filter Kelas (height: 31.0, gap: 8.0)
                  SizedBox(
                    height: 31.0,
                    child: Row(
                      children: List.generate(_gradeFilters.length, (index) {
                        final filter = _gradeFilters[index];
                        final bool isSelected = _selectedGradeFilter == filter;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < _gradeFilters.length - 1 ? 8.0 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGradeFilter = filter;
                                  // Reset specific class if it doesn't match the selected grade
                                  if (_selectedSpecificClass != null &&
                                      filter != 'Semua' &&
                                      !_selectedSpecificClass!
                                          .startsWith(filter)) {
                                    _selectedSpecificClass = null;
                                  }
                                });
                              },
                              child: Container(
                                height: isSelected ? 29.0 : 31.0,
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
                                  style: AppTextStyles.captionSemibold11
                                      .copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.pureWhite
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Tag Filter Aktif (bila ada filter selain default)
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
                          if (_selectedSortOption !=
                              StudentSortOption.nameAsc)
                            _buildActiveFilterChip(
                              _selectedSortOption.label,
                              () => setState(() => _selectedSortOption =
                                  StudentSortOption.nameAsc),
                            ),
                          if (_selectedSpecificClass != null)
                            _buildActiveFilterChip(
                              _selectedSpecificClass!,
                              () => setState(
                                  () => _selectedSpecificClass = null),
                            ),
                          if (_selectedGenderFilter != 'Semua')
                            _buildActiveFilterChip(
                              _selectedGenderFilter,
                              () => setState(
                                  () => _selectedGenderFilter = 'Semua'),
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
                                style: AppTextStyles.captionSemibold11
                                    .copyWith(
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
                  // Info Jumlah Siswa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Daftar Siswa Aktif (${students.length})',
                        style: AppTextStyles.cardTitle,
                      ),
                      const Text(
                        'TP 2026/2027',
                        style: AppTextStyles.captionSemibold11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  // List Card Siswa (gap: 10.0)
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 40.0,
                                  color: AppColors.textPlaceholder,
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  'Tidak ada siswa yang sesuai filter.',
                                  style: AppTextStyles.body,
                                ),
                                if (_hasActiveFilters) ...[
                                  const SizedBox(height: 8.0),
                                  GestureDetector(
                                    onTap: _resetFilters,
                                    child: Text(
                                      'Reset Filter',
                                      style: AppTextStyles.badgeBold10
                                          .copyWith(
                                        color: AppColors.primaryNavy,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              bottom: _isReadOnly ? 24.0 : 76.0,
                            ),
                            itemCount: students.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10.0),
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return StudentCard(
                                name: student.name,
                                nisn: student.nisn,
                                className: student.className,
                                onTap: () => _showStudentDetailSheet(student),
                                onLongPress: _isReadOnly
                                    ? null
                                    : () => _confirmDeleteStudent(student),
                              );
                            },
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
            // FAB Tambah Siswa (+) (58x58, r=18, fill=#1B3B7B)
            if (!_isReadOnly)
              Positioned(
                right: 20.0,
                bottom: 28.0,
                child: GestureDetector(
                  onTap: () => _showStudentFormSheet(),
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

class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16.0,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.subtitle11,
              ),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
