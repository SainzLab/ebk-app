import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/pb_client.dart';
import '../../models/case_model.dart';
import '../../repositories/case_repository.dart';
import '../../repositories/student_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';

/// Halaman Catat / Edit Kasus Pelanggaran (`07 • Tambah Kasus (SRS-F-004)`)
/// Mendukung pencatatan baru dan pengeditan kasus pelanggaran
/// (jenis kasus membolos, tawuran, dll; waktu; tempat; serta penanganan bimbingan).
class TambahKasusScreen extends StatefulWidget {
  final CaseRecordModel? initialCase;
  final VoidCallback? onBack;
  final bool isEmbedded;
  final ValueChanged<CaseRecordModel>? onSaveSuccess;

  const TambahKasusScreen({
    super.key,
    this.initialCase,
    this.onBack,
    this.isEmbedded = false,
    this.onSaveSuccess,
  });

  @override
  State<TambahKasusScreen> createState() => _TambahKasusScreenState();
}

class _TambahKasusScreenState extends State<TambahKasusScreen> {
  late final TextEditingController _siswaController;
  late DateTime _selectedIncidentDateTime;
  late final TextEditingController _tanggalController;
  late final TextEditingController _jamController;
  late final TextEditingController _waktuController;
  late final TextEditingController _tempatController;
  late final TextEditingController _kronologiController;
  late final TextEditingController _penangananController;
  late final TextEditingController _counselorController;

  late String _selectedCaseType;
  late String _selectedCategory;
  late bool _isCompleted;
  late int _violationPoints;

  bool get _isEditing => widget.initialCase != null;

  static const List<Map<String, String>> _predefinedStudents = [
    {
      'name': 'Rizky Pratama',
      'class': 'Kelas IX-B',
      'nisn': '0094821034',
    },
    {
      'name': 'Alya Putri Maharani',
      'class': 'Kelas VIII-A',
      'nisn': '0103948219',
    },
    {
      'name': 'Dimas Aditya Saputra',
      'class': 'Kelas VII-C',
      'nisn': '0112839401',
    },
    {
      'name': 'Fajar Nugraha',
      'class': 'Kelas VIII-B',
      'nisn': '0107462918',
    },
    {
      'name': 'Nabila Zahra Aulia',
      'class': 'Kelas IX-A',
      'nisn': '0098374612',
    },
    {
      'name': 'Salsabila Khairunnisa',
      'class': 'Kelas VII-A',
      'nisn': '0115920384',
    },
  ];

  static const List<Map<String, dynamic>> _caseTypes = [
    {
      'title': 'Membolos Sekolah saat Jam Efektif',
      'category': 'Kedisiplinan',
      'points': 25,
      'defaultLocation': 'Warung Kopi Belakang Pagar Sekolah',
    },
    {
      'title': 'Terlibat Tawuran / Perkelahian Antar Pelajar',
      'category': 'Perilaku & Ketertiban',
      'points': 50,
      'defaultLocation': 'Pertigaan Jalan Stasiun Pabuaran',
    },
    {
      'title': 'Kelengkapan Atribut Seragam Sekolah',
      'category': 'Tata Tertib Seragam',
      'points': 15,
      'defaultLocation': 'Gerbang Utama & Lapangan Upacara',
    },
    {
      'title': 'Keterlambatan Masuk Sekolah Berturut-turut',
      'category': 'Kedisiplinan',
      'points': 15,
      'defaultLocation': 'Pintu Masuk Gerbang Depan Sekolah',
    },
    {
      'title': 'Merokok / Menggunakan Vape di Area Sekolah',
      'category': 'Tata Tertib & Norma',
      'points': 35,
      'defaultLocation': 'Area Kamar Mandi Belakang Lab Komputer',
    },
    {
      'title': 'Perundungan (Bullying) & Tindakan Tidak Sopan',
      'category': 'Perilaku & Sikap',
      'points': 40,
      'defaultLocation': 'Koridor Kelas & Area Kantin',
    },
  ];

  late String _selectedStudentName;
  late String _selectedStudentClass;
  late String _selectedStudentNisn;
  List<Map<String, String>> _studentOptions = List.from(_predefinedStudents);

  @override
  void initState() {
    super.initState();
    _loadStudentsForPicker();
    final init = widget.initialCase;

    if (init != null) {
      _selectedStudentName = init.studentName;
      _selectedStudentClass = init.studentClass;
      _selectedStudentNisn = init.studentNisn;
      _selectedCaseType = init.caseTitle;
      _selectedCategory = init.caseCategory;
      _isCompleted = init.isCompleted;
      _violationPoints = init.violationPoints;

      _selectedIncidentDateTime = init.incidentDate ??
          CaseRecordModel.parseIncidentDateTime(init.incidentTime);

      _siswaController = TextEditingController(
        text: '$_selectedStudentName • $_selectedStudentClass ($_selectedStudentNisn)',
      );
      _tanggalController = TextEditingController(
        text: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedIncidentDateTime),
      );
      _jamController = TextEditingController(
        text: '${DateFormat('HH:mm').format(_selectedIncidentDateTime)} WIB',
      );
      _waktuController = TextEditingController(
        text: PbClient.formatDateTimeWib(_selectedIncidentDateTime),
      );
      _tempatController = TextEditingController(text: init.incidentLocation);
      _kronologiController = TextEditingController(text: init.chronology);
      _penangananController = TextEditingController(text: init.handling);
      _counselorController = TextEditingController(text: init.counselorName);
    } else {
      final defaultStudent = _predefinedStudents.first;
      _selectedStudentName = defaultStudent['name']!;
      _selectedStudentClass = defaultStudent['class']!;
      _selectedStudentNisn = defaultStudent['nisn']!;

      final defaultType = _caseTypes.first;
      _selectedCaseType = defaultType['title'] as String;
      _selectedCategory = defaultType['category'] as String;
      _violationPoints = defaultType['points'] as int;
      _isCompleted = false;

      _selectedIncidentDateTime = DateTime.now();

      _siswaController = TextEditingController(
        text: '$_selectedStudentName • $_selectedStudentClass ($_selectedStudentNisn)',
      );
      _tanggalController = TextEditingController(
        text: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedIncidentDateTime),
      );
      _jamController = TextEditingController(
        text: '${DateFormat('HH:mm').format(_selectedIncidentDateTime)} WIB',
      );
      _waktuController = TextEditingController(
        text: PbClient.formatDateTimeWib(_selectedIncidentDateTime),
      );
      _tempatController = TextEditingController(
        text: defaultType['defaultLocation'] as String,
      );
      _kronologiController = TextEditingController();
      _penangananController = TextEditingController();
      _counselorController = TextEditingController(text: 'Pak Budi, S.Pd.');
    }
  }

  void _updateDateTimeControllers() {
    _tanggalController.text =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedIncidentDateTime);
    _jamController.text =
        '${DateFormat('HH:mm').format(_selectedIncidentDateTime)} WIB';
    _waktuController.text =
        PbClient.formatDateTimeWib(_selectedIncidentDateTime);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedIncidentDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih Tanggal & Tahun Kejadian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
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
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedIncidentDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedIncidentDateTime.hour,
          _selectedIncidentDateTime.minute,
        );
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _selectedIncidentDateTime.hour,
        minute: _selectedIncidentDateTime.minute,
      ),
      helpText: 'Pilih Waktu / Jam Kejadian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
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
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedIncidentDateTime = DateTime(
          _selectedIncidentDateTime.year,
          _selectedIncidentDateTime.month,
          _selectedIncidentDateTime.day,
          picked.hour,
          picked.minute,
        );
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _loadStudentsForPicker() async {
    try {
      final list = await StudentRepository.instance.getStudents();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _studentOptions = list
              .map(
                (s) => {
                  'id': s.id,
                  'name': s.name,
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
    _siswaController.dispose();
    _tanggalController.dispose();
    _jamController.dispose();
    _waktuController.dispose();
    _tempatController.dispose();
    _kronologiController.dispose();
    _penangananController.dispose();
    _counselorController.dispose();
    super.dispose();
  }

  void _showStudentPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalBackdrop,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                const Text('Pilih Siswa', style: AppTextStyles.topBarTitle),
                const SizedBox(height: 10.0),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _studentOptions.length,
                    itemBuilder: (context, i) {
                      final s = _studentOptions[i];
                      final isSelected = s['name'] == _selectedStudentName;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 36.0,
                          height: 36.0,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 18.0,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        title: Text(
                          s['name']!,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: isSelected ? AppColors.primaryNavy : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${s['class']} • NISN: ${s['nisn']}',
                          style: AppTextStyles.subtitle11,
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryNavy)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedStudentName = s['name']!;
                            _selectedStudentClass = s['class']!;
                            _selectedStudentNisn = s['nisn']!;
                            _siswaController.text =
                                '$_selectedStudentName • $_selectedStudentClass ($_selectedStudentNisn)';
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCaseTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalBackdrop,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                const Text('Pilih Jenis Kasus Pelanggaran', style: AppTextStyles.topBarTitle),
                const SizedBox(height: 10.0),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _caseTypes.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.borderNeutral),
                    itemBuilder: (context, i) {
                      final item = _caseTypes[i];
                      final String title = item['title'] as String;
                      final String cat = item['category'] as String;
                      final int points = item['points'] as int;
                      final String defLoc = item['defaultLocation'] as String;
                      final isSelected = title == _selectedCaseType;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: isSelected ? AppColors.primaryNavy : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(cat, style: AppTextStyles.subtitle11),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: AppColors.errorSurface,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                '+$points Poin',
                                style: AppTextStyles.badgeBold10.copyWith(
                                  color: AppColors.errorPrimary,
                                  fontSize: 9.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryNavy)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCaseType = title;
                            _selectedCategory = cat;
                            _violationPoints = points;
                            if (_tempatController.text.isEmpty) {
                              _tempatController.text = defLoc;
                            }
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    final waktu = _waktuController.text.trim();
    final tempat = _tempatController.text.trim();
    final kronologi = _kronologiController.text.trim();
    final penanganan = _penangananController.text.trim();

    if (tempat.isEmpty || kronologi.isEmpty || penanganan.isEmpty) {
      ToastNotification.show(
        context,
        message: 'Mohon lengkapi Tempat Kejadian, Kronologi, dan Penanganan.',
        type: ToastType.error,
      );
      return;
    }

    final id = widget.initialCase?.id ??
        '#BK-${DateTime.now().year}-0${50 + DateTime.now().second % 40}';

    final incidentTimeFormatted =
        PbClient.formatDateTimeWib(_selectedIncidentDateTime);

    CaseRecordModel savedCase = CaseRecordModel(
      id: id,
      recordId: widget.initialCase?.recordId ?? '',
      studentId: widget.initialCase?.studentId ?? '',
      studentName: _selectedStudentName,
      studentNisn: _selectedStudentNisn,
      studentClass: _selectedStudentClass,
      caseCategory: _selectedCategory,
      caseTitle: _selectedCaseType,
      incidentDate: _selectedIncidentDateTime,
      incidentTime: incidentTimeFormatted,
      incidentLocation: tempat,
      chronology: kronologi,
      handling: penanganan,
      handlingDate: 'Hari Ini',
      counselorName: _counselorController.text.trim().isEmpty
          ? 'Pak Budi, S.Pd.'
          : _counselorController.text.trim(),
      isCompleted: _isCompleted,
      violationPoints: _violationPoints,
    );

    try {
      if (_isEditing) {
        savedCase = await CaseRepository.instance.updateCase(savedCase);
      } else {
        savedCase = await CaseRepository.instance.createCase(savedCase);
      }
    } catch (_) {}

    if (!mounted) return;
    if (widget.onSaveSuccess != null) {
      widget.onSaveSuccess!(savedCase);
    } else {
      Navigator.pop(context, savedCase);
    }
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
              // Top Bar Catat/Edit Kasus
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
                              color: AppColors.shadowBase.withValues(alpha: 0.031),
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
                      child: Center(
                        child: Text(
                          _isEditing ? 'Edit Data Kasus' : 'Catat Kasus Baru',
                          style: AppTextStyles.topBarTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40.0, height: 40.0),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),

              // Form Kontainer Putih
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 18.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: AppColors.borderSoft,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBase.withValues(alpha: 0.039),
                      offset: const Offset(0, 8),
                      blurRadius: 22.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Pilih Siswa
                    CustomTextField(
                      label: 'Pilih Siswa Terlibat *',
                      labelGap: 7.0,
                      containerHeight: 48.0,
                      readOnly: true,
                      onTap: _showStudentPicker,
                      controller: _siswaController,
                      hintText: 'Pilih nama siswa atau NISN...',
                      prefixIcon: Icons.person_outline_rounded,
                      prefixIconColor: AppColors.primaryNavy,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                      suffixIconColor: AppColors.textMuted,
                    ),
                    const SizedBox(height: 14.0),

                    // 2. Jenis Kasus Pelanggaran (Membolos / Tawuran / dll)
                    Row(
                      children: [
                        const Text('Jenis Kasus Pelanggaran *', style: AppTextStyles.label),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.errorSurface,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '+$_violationPoints Poin',
                            style: AppTextStyles.badgeBold10.copyWith(
                              color: AppColors.errorPrimary,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7.0),
                    GestureDetector(
                      onTap: _showCaseTypePicker,
                      child: Container(
                        width: double.infinity,
                        height: 48.0,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: AppColors.inputSurfaceGray,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.borderNeutral),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.assignment_late_outlined,
                              size: 18.0,
                              color: AppColors.primaryNavy,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                _selectedCaseType,
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.0,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // 3. Tanggal, Bulan, Tahun & Waktu Kejadian
                    CustomTextField(
                      label: 'Tanggal Kejadian (Tanggal, Bulan, Tahun) *',
                      labelGap: 7.0,
                      containerHeight: 48.0,
                      borderRadius: 12.0,
                      readOnly: true,
                      onTap: _pickDate,
                      controller: _tanggalController,
                      hintText: 'Pilih tanggal kejadian...',
                      prefixIcon: Icons.calendar_month_outlined,
                      prefixIconColor: AppColors.primaryNavy,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                      suffixIconColor: AppColors.textMuted,
                    ),
                    const SizedBox(height: 14.0),

                    CustomTextField(
                      label: 'Waktu / Jam Kejadian *',
                      labelGap: 7.0,
                      containerHeight: 48.0,
                      borderRadius: 12.0,
                      readOnly: true,
                      onTap: _pickTime,
                      controller: _jamController,
                      hintText: 'Pilih waktu kejadian...',
                      prefixIcon: Icons.access_time_rounded,
                      prefixIconColor: AppColors.primaryNavy,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                      suffixIconColor: AppColors.textMuted,
                    ),
                    const SizedBox(height: 14.0),

                    CustomTextField(
                      label: 'Tempat / Lokasi Kejadian *',
                      labelGap: 7.0,
                      containerHeight: 48.0,
                      controller: _tempatController,
                      hintText: 'Contoh: Warung Kopi Belakang Pagar Sekolah',
                      prefixIcon: Icons.location_on_outlined,
                      prefixIconColor: AppColors.primaryNavy,
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Deskripsi Kronologi
                    CustomTextField(
                      label: 'Deskripsi Kronologi Kejadian *',
                      rightLabel: 'Rinci & objektif',
                      labelGap: 7.0,
                      containerHeight: 100.0,
                      maxLines: 4,
                      controller: _kronologiController,
                      hintText:
                          'Tuliskan urutan kejadian, penyebab, saksi, dan kondisi saat insiden terjadi...',
                    ),
                    const SizedBox(height: 14.0),

                    // 5. Penanganan / Tindak Lanjut Guru BK
                    CustomTextField(
                      label: 'Tindakan / Pembinaan Guru BK *',
                      rightLabel: 'Solutif & edukatif',
                      labelGap: 7.0,
                      containerHeight: 100.0,
                      maxLines: 4,
                      controller: _penangananController,
                      hintText:
                          'Tuliskan langkah pembinaan (konseling individu, mediasi ortu, surat peringatan, pakta komitmen)...',
                    ),
                    const SizedBox(height: 14.0),

                    // 6. Status Kasus (Dalam Proses / Selesai)
                    const Text('Status Kasus Saat Ini', style: AppTextStyles.label),
                    const SizedBox(height: 7.0),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCompleted = false),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: !_isCompleted ? AppColors.warningBg : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: !_isCompleted ? AppColors.warningAccent : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Dalam Proses',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: !_isCompleted ? AppColors.warningText : AppColors.textSecondary,
                                  fontWeight: !_isCompleted ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCompleted = true),
                            child: Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: _isCompleted ? AppColors.successBg : AppColors.inputSurfaceGray,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: _isCompleted ? AppColors.successDot : AppColors.borderNeutral,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Selesai Dibina',
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: _isCompleted ? AppColors.successText : AppColors.textSecondary,
                                  fontWeight: _isCompleted ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomActionBar(
        showHomeIndicator: !widget.isEmbedded,
        child: CustomButton.primary(
          label: _isEditing ? 'Simpan Perubahan Kasus' : 'Simpan Catatan Kasus',
          leadingIcon: Icons.check_circle_outline_rounded,
          onPressed: _handleSave,
        ),
      ),
    );
  }
}
