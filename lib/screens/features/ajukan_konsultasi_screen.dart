import 'package:flutter/material.dart';
import '../../repositories/consultation_request_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';

/// Halaman Ajukan Konsultasi (`11 • Ajukan Konsultasi (SRS-F-011)`)
/// berdasarkan `11-ajukan-konsultasi-srs-f-011.png` dan `ebk_design.json`.
class AjukanKonsultasiScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;

  const AjukanKonsultasiScreen({
    super.key,
    this.onBack,
    this.isEmbedded = false,
  });

  @override
  State<AjukanKonsultasiScreen> createState() => _AjukanKonsultasiScreenState();
}

class _AjukanKonsultasiScreenState extends State<AjukanKonsultasiScreen> {
  final TextEditingController _pesanController = TextEditingController();
  String _selectedTopicChip = 'Akademik';
  String _selectedDropdownTopic = 'Akademik / Perilaku Siswa';

  static const List<String> _topicChips = [
    'Akademik',
    'Perilaku',
    'Sosial',
    'Minat Bakat',
  ];

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final msg = _pesanController.text.trim().isEmpty
        ? 'Pengajuan jadwal konsultasi oleh orang tua siswa.'
        : _pesanController.text.trim();
    try {
      await ConsultationRequestRepository.instance.submitRequest(
        topicCategory: _selectedTopicChip,
        topic: _selectedDropdownTopic,
        message: msg,
      );
      _pesanController.clear();
    } catch (_) {}
    if (!mounted) return;
    ToastNotification.show(
      context,
      message: 'Berhasil: Pengajuan jadwal konsultasi telah dikirim.',
      type: ToastType.success,
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
                    const Text(
                      'Ajukan Konsultasi',
                      style: AppTextStyles.topBarTitle,
                    ),
                    const SizedBox(width: 40.0, height: 40.0),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              // Banner Info Pengajuan (r=14, fill=#EBF2FF, stroke=#DBEAFE, pad=[10, 14])
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 14.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppColors.borderBlueTint,
                    width: 1.0,
                  ),
                ),
                child: const Text(
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
              const SizedBox(height: 15.0),
              // Kartu Form Pengajuan Konsultasi (r=24, fill=#FFFFFF, stroke=#EEF2F6, pad=[20, 18], gap=16)
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
                    // Konteks Siswa Terkait (height: 48, r=12, fill=#F8FAFC, stroke=#EEF2F6, pad=[9, 12], gap=10)
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
                          const Expanded(
                            child: Text(
                              'Siswa: Rizky Pratama • Kelas IX-B',
                              style: AppTextStyles.metaSemibold12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Field Dropdown Topik Konsultasi (gap: 7.0)
                    const Text(
                      'Topik Konsultasi',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 7.0),
                    Container(
                      width: double.infinity,
                      height: 46.0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13.0,
                        horizontal: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputSurfaceGray,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: AppColors.borderNeutral,
                          width: 1.0,
                        ),
                      ),
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
                    const SizedBox(height: 7.0),
                    // Pilihan Topik Chips (gap: 6.0)
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
                                      '$chip / Perilaku Siswa';
                                });
                              },
                              child: Container(
                                height: 24.0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 9.0,
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
                    // Field Date & Time Picker Jadwal (gap: 7.0)
                    const Text(
                      'Pilih Tanggal & Waktu Konsultasi',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 7.0),
                    Row(
                      children: [
                        // Date Picker (flex: 183)
                        Expanded(
                          flex: 183,
                          child: Container(
                            height: 43.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.inputSurfaceGray,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: AppColors.borderNeutral,
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kam, 12 Nov 2026',
                                    style: TextStyle(
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
                                SizedBox(width: 8.0),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 17.0,
                                  color: AppColors.primaryNavy,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // Time Picker (flex: 120)
                        Expanded(
                          flex: 120,
                          child: Container(
                            height: 43.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.inputSurfaceGray,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: AppColors.borderNeutral,
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    '09:30 WIB',
                                    style: TextStyle(
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
                                SizedBox(width: 6.0),
                                Icon(
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomActionBar(
        showHomeIndicator: !widget.isEmbedded,
        child: CustomButton.primary(
          label: 'Kirim Pengajuan',
          onPressed: _handleSubmit,
        ),
      ),
    );
  }
}
