import 'package:flutter/material.dart';
import '../../core/app_exception.dart';
import '../../models/student_model.dart';
import '../../repositories/consultation_request_repository.dart';
import '../../repositories/student_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';

/// Halaman Ajukan Konsultasi (`11 • Ajukan Konsultasi (SRS-F-011)`)
/// berdasarkan `11-ajukan-konsultasi-srs-f-011.png` dan `ebk_design.json`.
/// Seluruh field (siswa, topik, tanggal, waktu) interaktif dan memakai pola
/// UI/animasi yang sama dengan halaman Laporan Kasus & Kelola Kasus.
class AjukanKonsultasiScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSubmitSuccess;
  final bool isEmbedded;

  const AjukanKonsultasiScreen({
    super.key,
    this.onBack,
    this.onSubmitSuccess,
    this.isEmbedded = false,
  });

  @override
  State<AjukanKonsultasiScreen> createState() => _AjukanKonsultasiScreenState();
}

class _AjukanKonsultasiScreenState extends State<AjukanKonsultasiScreen> {
  final TextEditingController _pesanController = TextEditingController();
  String _selectedTopicChip = 'Akademik';
  String _selectedDropdownTopic = 'Akademik / Perilaku Siswa';

  List<StudentDataModel> _children = const [];
  String _selectedChildId = '';
  bool _isSubmitting = false;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  static const List<String> _topicChips = [
    'Akademik',
    'Perilaku',
    'Sosial',
    'Minat Bakat',
  ];

  static const Map<String, List<String>> _topicOptions = {
    'Akademik': [
      'Akademik / Perilaku Siswa',
      'Akademik / Nilai & Prestasi Belajar',
      'Akademik / Motivasi Belajar',
    ],
    'Perilaku': [
      'Perilaku / Perilaku Siswa',
      'Perilaku / Kedisiplinan & Tata Tertib',
      'Perilaku / Tindak Lanjut Kasus',
    ],
    'Sosial': [
      'Sosial / Perilaku Siswa',
      'Sosial / Pergaulan & Pertemanan',
      'Sosial / Perundungan',
    ],
    'Minat Bakat': [
      'Minat Bakat / Perilaku Siswa',
      'Minat Bakat / Pengembangan Diri',
      'Minat Bakat / Arahan Studi Lanjut',
    ],
  };

  static const List<String> _dayNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    _selectedTime = const TimeOfDay(hour: 9, minute: 30);
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final list = await StudentRepository.instance.getMyChildren();
      if (!mounted) return;
      setState(() {
        _children = list;
        if (list.isNotEmpty && _selectedChildId.isEmpty) {
          _selectedChildId = list.first.id;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  StudentDataModel? get _selectedChild {
    for (final c in _children) {
      if (c.id == _selectedChildId) return c;
    }
    return null;
  }

  String get _studentLabel {
    final c = _selectedChild;
    if (c == null) {
      return _children.isEmpty
          ? 'Belum ada siswa yang tertaut ke akun ini'
          : 'Pilih siswa';
    }
    return 'Siswa: ${c.name} • ${c.className}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  String get _dateLabel =>
      '${_dayNames[_selectedDate.weekday - 1]}, ${_two(_selectedDate.day)} '
      '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}';

  String get _timeLabel =>
      '${_two(_selectedTime.hour)}:${_two(_selectedTime.minute)} WIB';

  ThemeData _pickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primaryNavy,
            onPrimary: AppColors.pureWhite,
            surface: AppColors.pureWhite,
            onSurface: AppColors.textPrimary,
          ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      builder: (ctx, child) =>
          Theme(data: _pickerTheme(ctx), child: child ?? const SizedBox()),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) =>
          Theme(data: _pickerTheme(ctx), child: child ?? const SizedBox()),
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showTopicSheet() {
    final options = _topicOptions[_selectedTopicChip] ?? const <String>[];
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
                        Icons.chat_outlined,
                        size: 16.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Text(
                      'Pilih Topik Konsultasi',
                      style: AppTextStyles.topBarTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Divider(color: AppColors.borderNeutral, height: 1.0),
                const SizedBox(height: 12.0),
                for (final opt in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDropdownTopic = opt);
                        Navigator.of(sheetContext).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 14.0,
                        ),
                        decoration: BoxDecoration(
                          color: opt == _selectedDropdownTopic
                              ? AppColors.primaryNavy
                              : AppColors.inputSurfaceGray,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: opt == _selectedDropdownTopic
                                ? AppColors.primaryNavy
                                : AppColors.borderNeutral,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: AppTextStyles.metaSemibold12.copyWith(
                                  color: opt == _selectedDropdownTopic
                                      ? AppColors.pureWhite
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (opt == _selectedDropdownTopic)
                              const Icon(
                                Icons.check_rounded,
                                size: 16.0,
                                color: AppColors.pureWhite,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (_selectedChildId.isEmpty) {
      ToastNotification.show(
        context,
        message: 'Gagal: Belum ada siswa yang tertaut ke akun ini.',
        type: ToastType.error,
      );
      return;
    }
    final msg = _pesanController.text.trim().isEmpty
        ? 'Pengajuan jadwal konsultasi oleh orang tua siswa.'
        : _pesanController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      await ConsultationRequestRepository.instance.submitRequest(
        topicCategory: _selectedTopicChip,
        topic: _selectedDropdownTopic,
        message: msg,
        preferredDate:
            '${_selectedDate.year}-${_two(_selectedDate.month)}-${_two(_selectedDate.day)}',
        preferredTime: '${_two(_selectedTime.hour)}:${_two(_selectedTime.minute)}',
        studentId: _selectedChildId,
      );
      if (!mounted) return;
      _pesanController.clear();
      setState(() => _isSubmitting = false);
      ToastNotification.show(
        context,
        message: 'Berhasil: Pengajuan jadwal konsultasi telah dikirim.',
        type: ToastType.success,
      );
      widget.onSubmitSuccess?.call();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ToastNotification.show(
        context,
        message: 'Gagal: ${e.message}',
        type: ToastType.error,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ToastNotification.show(
        context,
        message: 'Gagal: Pengajuan tidak dapat dikirim. Coba lagi.',
        type: ToastType.error,
      );
    }
  }

  /// Animasi kemunculan bertahap (fade + slide-up), sama dengan daftar kasus.
  Widget _entrance(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + (index * 70).clamp(0, 420)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, c) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1.0 - value)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  Widget _fieldBox({
    required VoidCallback onTap,
    required double height,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Ink(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: AppColors.inputSurfaceGray,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: AppColors.borderNeutral, width: 1.0),
          ),
          child: child,
        ),
      ),
    );
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
              // Top Bar Ajukan Konsultasi (height: 44.0)
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
                        'Ajukan Konsultasi',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.topBarTitle,
                      ),
                    ),
                    const SizedBox(width: 40.0, height: 40.0),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              // Banner Info Pengajuan
              _entrance(
                0,
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
                          'Pilih topik dan usulan waktu pertemuan. Guru BK akan mengonfirmasi jadwal konsultasi Anda.',
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
              ),
              const SizedBox(height: 14.0),
              // Kartu Form Pengajuan Konsultasi
              _entrance(
                1,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Konteks Siswa Terkait
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 9.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputSurfaceGray,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: AppColors.borderSoft,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_outline_rounded,
                                size: 16.0,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                _studentLabel,
                                style: AppTextStyles.metaSemibold12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pilih Siswa (bila wali memiliki lebih dari 1 anak)
                      if (_children.length > 1) ...[
                        const SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final c in _children)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedChildId = c.id),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      height: 31.0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedChildId == c.id
                                            ? AppColors.primaryNavy
                                            : AppColors.pureWhite,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                        border: _selectedChildId == c.id
                                            ? null
                                            : Border.all(
                                                color: AppColors.borderNeutral,
                                              ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        c.name,
                                        style: AppTextStyles.captionSemibold11
                                            .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: _selectedChildId == c.id
                                              ? AppColors.pureWhite
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      // Field Dropdown Topik Konsultasi
                      const Text(
                        'Topik Konsultasi',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 7.0),
                      _fieldBox(
                        onTap: _showTopicSheet,
                        height: 46.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_outlined,
                              size: 18.0,
                              color: AppColors.primaryNavy,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                _selectedDropdownTopic,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13.0,
                                  height: 18.0 / 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
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
                      const SizedBox(height: 8.0),
                      // Pilihan Topik Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _topicChips.map((chip) {
                            final bool isSelected = _selectedTopicChip == chip;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTopicChip = chip;
                                    _selectedDropdownTopic =
                                        _topicOptions[chip]!.first;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 26.0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryTint
                                        : AppColors.inputSurfaceGray,
                                    borderRadius: BorderRadius.circular(99.0),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.borderBlueAccent
                                          : AppColors.borderNeutral,
                                      width: 1.0,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    chip,
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 10.0,
                                      height: 14.0 / 10.0,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Field Date & Time Picker Jadwal
                      const Text(
                        'Pilih Tanggal & Waktu Konsultasi',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 7.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 183,
                            child: _fieldBox(
                              onTap: _pickDate,
                              height: 43.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _dateLabel,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 12.0,
                                        height: 17.0 / 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 17.0,
                                    color: AppColors.primaryNavy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            flex: 120,
                            child: _fieldBox(
                              onTap: _pickTime,
                              height: 43.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _timeLabel,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 12.0,
                                        height: 17.0 / 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 15.0,
                                    color: AppColors.primaryNavy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // Field Text Area Pesan Alasan Tambahan
                      CustomTextField(
                        label: 'Pesan/Alasan Tambahan',
                        rightLabel: 'Opsional',
                        labelGap: 7.0,
                        containerHeight: 120.0,
                        maxLines: 4,
                        maxLengthCounter: 300,
                        contentPadding: const EdgeInsets.fromLTRB(
                          14.0,
                          12.0,
                          14.0,
                          10.0,
                        ),
                        controller: _pesanController,
                        hintText:
                            'Tuliskan hal yang ingin didiskusikan atau alasan pengajuan jadwal konsultasi bersama Guru BK...',
                        hintStyle: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.0,
                          height: 18.0 / 12.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPlaceholder,
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
      bottomNavigationBar: CustomBottomActionBar(
        showHomeIndicator: !widget.isEmbedded,
        child: CustomButton.primary(
          label: _isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan',
          onPressed: _isSubmitting ? null : _handleSubmit,
        ),
      ),
    );
  }
}
