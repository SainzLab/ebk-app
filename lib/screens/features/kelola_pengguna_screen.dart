import 'package:flutter/material.dart';
import '../../models/user_account_model.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/user_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';
import '../../widgets/animated_dialog.dart';

/// Halaman Kelola Pengguna - Akun Orang Tua (`13 • Kelola Pengguna (SRS-F-007)`)
/// Berdasarkan spesifikasi `ebk_design.json` dan gambar desain sistem.
/// Menyediakan fitur CRUD lengkap untuk Akun Orang Tua Siswa:
/// 1. Melihat daftar akun orang tua terdaftar.
/// 2. Menambah akun orang tua baru (Wali, Siswa Asuh, Kontak, Kredensial).
/// 3. Mengedit data akun orang tua, siswa asuh terkait, dan status keaktifan.
/// 4. Menghapus akun orang tua dengan dialog konfirmasi aman.
/// 5. Filter tab keaktifan, filter kelas siswa, pengurutan, dan pencarian real-time.
class KelolaPenggunaScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;

  const KelolaPenggunaScreen({
    super.key,
    this.onBack,
    this.isEmbedded = false,
  });

  @override
  State<KelolaPenggunaScreen> createState() => _KelolaPenggunaScreenState();
}

class _KelolaPenggunaScreenState extends State<KelolaPenggunaScreen> {
  late List<UserAccountModel> _accounts;

  // Tab Filter Status: 0 = Semua, 1 = Aktif, 2 = Nonaktif
  int _selectedStatusTab = 0;

  // Controller Pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter Tingkat Kelas & Urutan
  String _classFilter = 'Semua';
  String _sortBy = 'Nama Wali (A – Z)';

  static const List<String> _classOptions = [
    'Semua',
    'Kelas VII',
    'Kelas VIII',
    'Kelas IX',
  ];

  static const List<Map<String, String>> _availableStudents = [
    {
      'child': 'Rizky Pratama',
      'class': 'Kelas IX-B',
      'nisn': '0081234567',
    },
    {
      'child': 'Alya Putri Maharani',
      'class': 'Kelas VIII-A',
      'nisn': '0098765432',
    },
    {
      'child': 'Dimas Aditya Saputra',
      'class': 'Kelas VII-C',
      'nisn': '0105678912',
    },
    {
      'child': 'Farhan Maulana',
      'class': 'Kelas IX-A',
      'nisn': '0087654321',
    },
    {
      'child': 'Siti Nurhaliza',
      'class': 'Kelas VIII-B',
      'nisn': '0091238901',
    },
    {
      'child': 'Budi Santoso',
      'class': 'Kelas VII-A',
      'nisn': '0103456789',
    },
  ];

  List<Map<String, String>> _studentOptions = List.from(_availableStudents);

  @override
  void initState() {
    super.initState();
    _accounts = UserAccountModel.getInitialAccounts();
    _loadAccountsFromPocketBase();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadAccountsFromPocketBase() async {
    try {
      final list = await UserRepository.instance.getParentAccounts();
      if (mounted) {
        setState(() {
          _accounts = list;
        });
      }
      final students = await StudentRepository.instance.getStudents();
      if (mounted && students.isNotEmpty) {
        setState(() {
          _studentOptions = students
              .map(
                (s) => {
                  'child': s.name,
                  'class': s.className,
                  'nisn': s.nisn,
                },
              )
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _selectedStatusTab != 0 ||
        _classFilter != 'Semua' ||
        _sortBy != 'Nama Wali (A – Z)' ||
        _searchQuery.isNotEmpty;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedStatusTab = 0;
      _classFilter = 'Semua';
      _sortBy = 'Nama Wali (A – Z)';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<UserAccountModel> get _filteredAccounts {
    final list = _accounts.where((user) {
      // Filter Tab Keaktifan
      if (_selectedStatusTab == 1 && !user.isActive) {
        return false;
      }
      if (_selectedStatusTab == 2 && user.isActive) {
        return false;
      }

      // Filter Pencarian Teks
      if (_searchQuery.isNotEmpty) {
        final matches = user.fullName.toLowerCase().contains(_searchQuery) ||
            user.username.toLowerCase().contains(_searchQuery) ||
            user.emailOrPhone.toLowerCase().contains(_searchQuery) ||
            user.studentChildName.toLowerCase().contains(_searchQuery) ||
            user.studentClass.toLowerCase().contains(_searchQuery) ||
            user.studentNisn.contains(_searchQuery);
        if (!matches) return false;
      }

      // Filter Kelas
      if (_classFilter != 'Semua') {
        if (!user.studentClass.contains(_classFilter.replaceAll('Kelas ', ''))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    if (_sortBy == 'Nama Wali (A – Z)') {
      list.sort((a, b) => a.fullName.compareTo(b.fullName));
    } else if (_sortBy == 'Nama Wali (Z – A)') {
      list.sort((a, b) => b.fullName.compareTo(a.fullName));
    } else if (_sortBy == 'Nama Siswa (A – Z)') {
      list.sort((a, b) => a.studentChildName.compareTo(b.studentChildName));
    } else if (_sortBy == 'Terbaru Ditambahkan') {
      list.sort((a, b) => b.id.compareTo(a.id));
    }

    return list;
  }

  // Modal Sheet: Filter & Urutkan
  void _showFilterSortSheet() {
    String tempSort = _sortBy;
    String tempClass = _classFilter;

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Akun Orang Tua',
                          style: AppTextStyles.heading2,
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSort = 'Nama Wali (A – Z)';
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
                        'Nama Wali (A – Z)',
                        'Nama Wali (Z – A)',
                        'Nama Siswa (A – Z)',
                        'Terbaru Ditambahkan',
                      ].map((sortOption) {
                        return _FilterChipWidget(
                          label: sortOption,
                          isSelected: tempSort == sortOption,
                          onTap: () => setModalState(() => tempSort = sortOption),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Filter Tingkat Kelas Siswa
                    const Text('Tingkat Kelas Siswa Asuh',
                        style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: _classOptions.map((c) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: _FilterChipWidget(
                              label: c,
                              isSelected: tempClass == c,
                              onTap: () => setModalState(() => tempClass = c),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24.0),

                    CustomButton(
                      label: 'Terapkan Filter',
                      height: 50.0,
                      onPressed: () {
                        setState(() {
                          _sortBy = tempSort;
                          _classFilter = tempClass;
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

  // Dialog Konfirmasi Hapus Akun Aman dengan animasi pop-up menarik
  void _confirmDeleteAccount(UserAccountModel user) {
    showAnimatedDialog(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.45),
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowBase.withValues(alpha: 0.12),
                  offset: const Offset(0, 10),
                  blurRadius: 30.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 28.0,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Hapus Akun Orang Tua?',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Akun ${user.fullName} (Wali dari ${user.studentChildName}) akan dihapus secara permanen dari sistem E-BK.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Batal',
                        variant: CustomButtonVariant.secondary,
                        height: 44.0,
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: CustomButton(
                        label: 'Ya, Hapus',
                        variant: CustomButtonVariant.danger,
                        height: 44.0,
                        onPressed: () async {
                          Navigator.pop(dialogCtx);
                          try {
                            if (!user.id.startsWith('ORTU-')) {
                              await UserRepository.instance
                                  .deleteParentAccount(user.id);
                            }
                          } catch (_) {}
                          if (!mounted) return;
                          setState(() {
                            _accounts.removeWhere((a) => a.id == user.id);
                          });
                          ToastNotification.show(
                            context,
                            message:
                                'Akun ${user.fullName} telah berhasil dihapus.',
                            type: ToastType.success,
                          );
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

  // Modal Form Tambah / Edit Akun Orang Tua
  void _showAccountFormSheet({UserAccountModel? editItem}) {
    final bool isEdit = editItem != null;
    final nameCtrl =
        TextEditingController(text: isEdit ? editItem.fullName : '');
    final usernameCtrl =
        TextEditingController(text: isEdit ? editItem.username : '');
    final emailCtrl = TextEditingController(
        text: isEdit && editItem.hasRealEmail ? editItem.email : '');
    final phoneCtrl =
        TextEditingController(text: isEdit ? editItem.phone : '');
    final passwordCtrl =
        TextEditingController(text: isEdit ? '••••••••' : '12345678');

    final studentList = List<Map<String, String>>.from(
      _studentOptions.isNotEmpty ? _studentOptions : _availableStudents,
    );

    // Deduplikasi daftar siswa agar tidak ada duplikasi item
    final seenKeys = <String>{};
    studentList.retainWhere((s) {
      final key = '${s['nisn'] ?? ''}_${s['child'] ?? ''}';
      return seenKeys.add(key);
    });

    String getStudentKey(Map<String, String> s) =>
        '${s['nisn'] ?? ''}_${s['child'] ?? ''}';

    // Seorang wali boleh memiliki lebih dari satu anak di sekolah yang sama.
    final List<Map<String, String>> selectedStudents = [];
    if (isEdit) {
      if (editItem.children.isNotEmpty) {
        for (final c in editItem.children) {
          selectedStudents.add({
            'child': c.name,
            'class': c.className,
            'nisn': c.nisn,
          });
        }
      } else if (editItem.studentNisn.isNotEmpty &&
          editItem.studentNisn != '-') {
        selectedStudents.add({
          'child': editItem.studentChildName.split(' (+').first,
          'class': editItem.studentClass,
          'nisn': editItem.studentNisn,
        });
      }
    }
    for (final sel in selectedStudents) {
      if (!studentList.any((s) => getStudentKey(s) == getStudentKey(sel))) {
        studentList.insert(0, sel);
      }
    }

    bool isActiveStatus = isEdit ? editItem.isActive : true;

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
                          ? 'Edit Akun ${editItem.fullName}'
                          : 'Tambah Akun Orang Tua',
                      style: AppTextStyles.heading2,
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        'Wali dari: ${editItem.studentChildName} (${editItem.studentClass})',
                        style: AppTextStyles.subtitle11,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14.0),

                    // 1. Nama Lengkap Wali Murid
                    const Text('Nama Lengkap Orang Tua / Wali',
                        style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: nameCtrl,
                      hintText: 'Contoh: Bapak Hendra Pratama',
                      prefixIcon: Icons.family_restroom_rounded,
                    ),
                    const SizedBox(height: 14.0),

                    // 2. Siswa Asuh Terkait (bisa lebih dari satu anak)
                    const Text('Wali dari Siswa', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    if (selectedStudents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Belum ada siswa dipilih. Tambahkan minimal satu siswa.',
                          style: AppTextStyles.subtitle11,
                        ),
                      ),
                    for (final st in selectedStudents)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.only(
                            left: 14.0, top: 6.0, bottom: 6.0, right: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: AppColors.borderBlueTint,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${st['child'] ?? '-'} • ${st['class'] ?? '-'} (${st['nisn'] ?? '-'})',
                                style: AppTextStyles.body,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close_rounded,
                                  size: 18.0, color: AppColors.errorPrimary),
                              onPressed: () => setModalState(() {
                                selectedStudents.removeWhere((x) =>
                                    getStudentKey(x) == getStudentKey(st));
                              }),
                            ),
                          ],
                        ),
                      ),
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
                        child: DropdownButton<String>(
                          value: null,
                          isExpanded: true,
                          hint: const Text(
                            '+ Tambah siswa asuh',
                            style: AppTextStyles.body,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryNavy,
                          ),
                          items: studentList
                              .where((s) => !selectedStudents.any((x) =>
                                  getStudentKey(x) == getStudentKey(s)))
                              .map((s) {
                            return DropdownMenuItem<String>(
                              value: getStudentKey(s),
                              child: Text(
                                '${s['child'] ?? '-'} • ${s['class'] ?? '-'} (${s['nisn'] ?? '-'})',
                                style: AppTextStyles.body,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setModalState(() {
                              selectedStudents.add(studentList.firstWhere(
                                  (s) => getStudentKey(s) == val));
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 3. Email
                    const Text('Email', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: emailCtrl,
                      hintText: 'Contoh: hendra.pratama@gmail.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Nomor Telepon / WhatsApp
                    const Text('Nomor Telepon / WhatsApp',
                        style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: phoneCtrl,
                      hintText: 'Contoh: 08123456789',
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Username & Password Awal
                    const Text('Username Akun', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: usernameCtrl,
                      hintText: 'Contoh: hendra.pratama',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 14.0),

                    const Text('Kata Sandi', style: AppTextStyles.label),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      controller: passwordCtrl,
                      isPassword: true,
                      hintText: 'Masukkan kata sandi akun...',
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 14.0),

                    // 5. Status Keaktifan Akun (Tanpa Dot)
                    const Text('Status Keaktifan Akun',
                        style: AppTextStyles.label),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => isActiveStatus = true),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: isActiveStatus
                                    ? AppColors.successBg
                                    : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isActiveStatus
                                      ? AppColors.successBorder
                                      : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Akun Aktif',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: isActiveStatus
                                      ? AppColors.successText
                                      : AppColors.textSecondary,
                                  fontWeight: isActiveStatus
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
                                setModalState(() => isActiveStatus = false),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: !isActiveStatus
                                    ? AppColors.canvasLightGray
                                    : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: !isActiveStatus
                                      ? AppColors.borderNeutral
                                      : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Nonaktif',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: !isActiveStatus
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: !isActiveStatus
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
                      label: isEdit
                          ? 'Simpan Perubahan'
                          : 'Simpan Akun Orang Tua',
                      height: 50.0,
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            usernameCtrl.text.trim().isEmpty) {
                          ToastNotification.show(
                            context,
                            message:
                                'Peringatan: Mohon lengkapi nama wali dan username akun.',
                            type: ToastType.error,
                          );
                          return;
                        }

                        if (selectedStudents.isEmpty) {
                          ToastNotification.show(
                            context,
                            message: 'Pilih minimal satu siswa asuh.',
                            type: ToastType.error,
                          );
                          return;
                        }
                        final firstStudent = selectedStudents.first;
                        final extraKids = selectedStudents.length - 1;
                        final childSummary = extraKids > 0
                            ? '${firstStudent['child']} (+$extraKids anak)'
                            : (firstStudent['child'] ?? '-');
                        final emailVal = emailCtrl.text.trim();
                        final phoneVal = phoneCtrl.text.trim();
                        if (emailVal.isNotEmpty &&
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(emailVal)) {
                          ToastNotification.show(
                            context,
                            message: 'Format email tidak valid.',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (phoneVal.isNotEmpty &&
                            !RegExp(r'^\+?[0-9\s\-]{8,16}$')
                                .hasMatch(phoneVal)) {
                          ToastNotification.show(
                            context,
                            message:
                                'Nomor telepon tidak valid (8-16 digit).',
                            type: ToastType.error,
                          );
                          return;
                        }

                        if (isEdit) {
                          final idx = _accounts
                              .indexWhere((a) => a.id == editItem.id);
                          if (idx != -1) {
                            var updatedAcc = _accounts[idx].copyWith(
                              fullName: nameCtrl.text.trim(),
                              username: usernameCtrl.text.trim(),
                              email: emailVal,
                              phone: phoneVal,
                              studentChildName: childSummary,
                              studentClass: firstStudent['class'] ?? '-',
                              studentNisn: firstStudent['nisn'] ?? '-',
                              isActive: isActiveStatus,
                            );
                            final pwd = passwordCtrl.text.trim();
                            try {
                              if (!editItem.id.startsWith('ORTU-')) {
                                updatedAcc = await UserRepository.instance
                                    .updateParentAccount(
                                  account: updatedAcc,
                                  students: selectedStudents,
                                  newPassword:
                                      (pwd != '••••••••' && pwd.length >= 8)
                                          ? pwd
                                          : null,
                                );
                              }
                            } catch (_) {}
                            if (mounted) {
                              setState(() {
                                _accounts[idx] = updatedAcc;
                              });
                            }
                          }
                        } else {
                          final newId = 'ORTU-00${_accounts.length + 1}';
                          var newAcc = UserAccountModel(
                            id: newId,
                            fullName: nameCtrl.text.trim(),
                            username: usernameCtrl.text.trim(),
                            email: emailVal,
                              phone: phoneVal,
                            studentChildName: childSummary,
                            studentClass: firstStudent['class'] ?? '-',
                            studentNisn: firstStudent['nisn'] ?? '-',
                            isActive: isActiveStatus,
                            createdAt: 'Hari ini',
                          );
                          try {
                            newAcc = await UserRepository.instance
                                .createParentAccount(
                              account: newAcc,
                              students: selectedStudents,
                              password: passwordCtrl.text.trim(),
                            );
                          } catch (_) {}
                          if (mounted) {
                            setState(() {
                              _accounts.insert(0, newAcc);
                            });
                          }
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (!mounted) return;
                        ToastNotification.show(
                          context,
                          message: isEdit
                              ? 'Akun orang tua ${nameCtrl.text.trim()} berhasil diperbarui.'
                              : 'Berhasil: Akun orang tua ${nameCtrl.text.trim()} telah dibuat.',
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

  // Modal Detail Akun Orang Tua
  void _showDetailSheet(UserAccountModel user) {
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        user.studentClass.isNotEmpty && user.studentClass != '-'
                            ? 'Wali ${user.studentClass}'
                            : 'Wali Murid',
                        style: AppTextStyles.badgeBold10,
                      ),
                    ),
                    // Status Badge (Tanpa Dot)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? AppColors.successBg
                            : AppColors.canvasLightGray,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        user.isActive ? 'Akun Aktif' : 'Nonaktif',
                        style: AppTextStyles.captionSemibold11.copyWith(
                          color: user.isActive
                              ? AppColors.successText
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),

                Row(
                  children: [
                    Container(
                      width: 52.0,
                      height: 52.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.family_restroom_rounded,
                        size: 28.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: AppTextStyles.heading2),
                          const SizedBox(height: 2.0),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                  horizontal: 7.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                                child: const Text(
                                  'Orang Tua',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                '@${user.username}',
                                style: AppTextStyles.subtitle11,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18.0),
                const Divider(height: 1.0, color: AppColors.borderNeutral),
                const SizedBox(height: 16.0),

                _DetailInfoTile(
                  label: 'Siswa Asuh (Anak)',
                  value:
                      '${user.studentChildName} • ${user.studentClass} (NISN: ${user.studentNisn})',
                  icon: Icons.person_pin_circle_outlined,
                ),
                const SizedBox(height: 10.0),
                _DetailInfoTile(
                  label: 'Email Terdaftar',
                  value: user.hasRealEmail ? user.email : '-',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 10.0),
                _DetailInfoTile(
                  label: 'Nomor Telepon / WhatsApp',
                  value: user.phone.isNotEmpty ? user.phone : '-',
                  icon: Icons.phone_android_rounded,
                ),
                const SizedBox(height: 10.0),
                _DetailInfoTile(
                  label: 'Tanggal Pembuatan Akun',
                  value: user.createdAt,
                  icon: Icons.event_available_outlined,
                ),
                const SizedBox(height: 22.0),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Edit Akun',
                        variant: CustomButtonVariant.secondary,
                        height: 44.0,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAccountFormSheet(editItem: user);
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: CustomButton(
                        label: 'Hapus Akun',
                        variant: CustomButtonVariant.danger,
                        height: 44.0,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDeleteAccount(user);
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
    final filteredList = _filteredAccounts;
    final activeCount = _accounts.where((a) => a.isActive).length;
    final inactiveCount = _accounts.where((a) => !a.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar Kelola Akun Orang Tua
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
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Kelola Pengguna',
                          style: AppTextStyles.topBarTitle,
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          'Akun Orang Tua Siswa',
                          style: AppTextStyles.subtitle11,
                        ),
                      ],
                    ),
                  ),
                  // Tombol Filter Interaktif
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

            // Segmented Status Filter (Semua, Akun Aktif, Nonaktif)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 41.0,
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
                    _SegmentTab(
                      label: 'Semua (${_accounts.length})',
                      isSelected: _selectedStatusTab == 0,
                      onTap: () => setState(() => _selectedStatusTab = 0),
                    ),
                    const SizedBox(width: 4.0),
                    _SegmentTab(
                      label: 'Akun Aktif ($activeCount)',
                      isSelected: _selectedStatusTab == 1,
                      onTap: () => setState(() => _selectedStatusTab = 1),
                    ),
                    const SizedBox(width: 4.0),
                    _SegmentTab(
                      label: 'Nonaktif ($inactiveCount)',
                      isSelected: _selectedStatusTab == 2,
                      onTap: () => setState(() => _selectedStatusTab = 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // Bilah Pencarian Akun Orang Tua
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomTextField(
                controller: _searchController,
                hintText: 'Cari nama orang tua, siswa, atau email...',
                prefixIcon: Icons.search_rounded,
                suffixIcon:
                    _searchQuery.isNotEmpty ? Icons.close_rounded : null,
                onSuffixTap: () {
                  _searchController.clear();
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
                                onRemove: () => _searchController.clear(),
                              ),
                            if (_selectedStatusTab != 0)
                              _ActiveTagChip(
                                label: _selectedStatusTab == 1
                                    ? 'Status: Aktif'
                                    : 'Status: Nonaktif',
                                onRemove: () =>
                                    setState(() => _selectedStatusTab = 0),
                              ),
                            if (_classFilter != 'Semua')
                              _ActiveTagChip(
                                label: _classFilter,
                                onRemove: () =>
                                    setState(() => _classFilter = 'Semua'),
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

            // Header Daftar Akun & Counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Daftar Akun Orang Tua',
                    style: AppTextStyles.sectionHeader14,
                  ),
                  Text(
                    '$activeCount Aktif • $inactiveCount Nonaktif',
                    style: AppTextStyles.subtitle11.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),

            // Daftar List Akun Pengguna Orang Tua
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.manage_accounts_outlined,
                            size: 48.0,
                            color: AppColors.textPlaceholder,
                          ),
                          const SizedBox(height: 12.0),
                          const Text(
                            'Tidak ada akun orang tua yang cocok',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'Coba ubah kata kunci atau kriteria pencarian.',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 14.0),
                          TextButton(
                            onPressed: _resetAllFilters,
                            child: const Text('Reset Filter'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 96.0),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10.0),
                      itemBuilder: (context, index) {
                        final user = filteredList[index];
                        return _ParentAccountCardItem(
                          user: user,
                          onTap: () => _showDetailSheet(user),
                          onEdit: () => _showAccountFormSheet(editItem: user),
                          onDelete: () => _confirmDeleteAccount(user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, widget.isEmbedded ? 10.0 : 18.0),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBase.withValues(alpha: 0.06),
              offset: const Offset(0, -4),
              blurRadius: 16.0,
            ),
          ],
        ),
        child: CustomButton.primary(
          label: 'Tambah Akun Orang Tua',
          leadingIcon: Icons.add_rounded,
          height: 50.0,
          onPressed: () => _showAccountFormSheet(),
        ),
      ),
    );
  }
}

/// Widget Kartu Akun Orang Tua sesuai spesifikasi Frame `13 • Kelola Pengguna`
class _ParentAccountCardItem extends StatelessWidget {
  final UserAccountModel user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ParentAccountCardItem({
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.borderNeutral,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.025),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Avatar Icon Squircle (38x38, r=11)
                      Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(11.0),
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
                            // Nama & Badge Role (Tanpa Dot)
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.fullName,
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
                                ),
                                const SizedBox(width: 6.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                    horizontal: 7.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius:
                                        BorderRadius.circular(99.0),
                                  ),
                                  child: const Text(
                                    'Orang Tua',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            // Subtitle Detail Siswa Asuh
                            Text(
                              'Wali dari: ${user.studentChildName} (${user.studentClass})',
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
                const SizedBox(width: 8.0),

                // Action Buttons: Edit & Delete (30x30, r=9)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(9.0),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 14.0,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(9.0),
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 14.0,
                          color: Color(0xFFDC2626),
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

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 31.0,
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? AppColors.pureWhite
                  : AppColors.textSecondary,
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

class _DetailInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: AppColors.canvasLightGray,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: AppColors.primaryNavy),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 1.0),
                Text(value, style: AppTextStyles.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
