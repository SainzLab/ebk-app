import 'package:flutter/material.dart';
import '../../models/case_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/toast_notification.dart';
import '../dashboard/profil_view.dart';
import '../states/delete_dialog.dart';
import 'tambah_kasus_screen.dart';

/// Halaman Detail Kasus Pelanggaran Siswa (`10 • Detail Kasus (SRS-F-008 & 009)`)
/// Menampilkan rincian jenis kasus (membolos, tawuran, dll), waktu, tempat,
/// kronologi, penanganan Guru BK, serta aksi Edit dan Ubah Status.
/// Untuk role Kepala Sekolah, menu dibatasi hanya untuk melihat (read-only)
/// tanpa aksi edit, hapus, maupun menandai selesai.
class DetailKasusScreen extends StatefulWidget {
  final CaseRecordModel? caseData;
  final VoidCallback? onBack;
  final ValueChanged<CaseRecordModel>? onOpenEdit;
  final bool isReadOnly;
  final ProfilRole? role;

  const DetailKasusScreen({
    super.key,
    this.caseData,
    this.onBack,
    this.onOpenEdit,
    this.isReadOnly = false,
    this.role,
  });

  @override
  State<DetailKasusScreen> createState() => _DetailKasusScreenState();
}

class _DetailKasusScreenState extends State<DetailKasusScreen> {
  late CaseRecordModel _currentCase;

  bool get _isReadOnly {
    if (widget.isReadOnly ||
        widget.role == ProfilRole.kepalaSekolah ||
        widget.role == ProfilRole.orangTua) {
      return true;
    }
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic>) {
      if (routeArgs['isReadOnly'] == true ||
          routeArgs['role'] == ProfilRole.kepalaSekolah ||
          routeArgs['role'] == ProfilRole.orangTua ||
          routeArgs['role'] == 'kepsek' ||
          routeArgs['role'] == 'kepala_sekolah' ||
          routeArgs['role'] == 'ortu' ||
          routeArgs['role'] == 'orang_tua') {
        return true;
      }
    } else if (routeArgs is ProfilRole &&
        (routeArgs == ProfilRole.kepalaSekolah ||
            routeArgs == ProfilRole.orangTua)) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _currentCase = widget.caseData ?? CaseRecordModel.defaultCases.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.caseData == null) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is Map<String, dynamic> &&
          routeArgs['caseData'] is CaseRecordModel) {
        _currentCase = routeArgs['caseData'] as CaseRecordModel;
      } else if (routeArgs is CaseRecordModel) {
        _currentCase = routeArgs;
      }
    }
  }

  @override
  void didUpdateWidget(covariant DetailKasusScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.caseData != oldWidget.caseData && widget.caseData != null) {
      _currentCase = widget.caseData!;
    }
  }

  void _handleEditCase() async {
    if (_isReadOnly) {
      ToastNotification.show(
        context,
        message:
            'Akses ditolak: Kepala Sekolah hanya memiliki izin melihat riwayat kasus.',
        type: ToastType.error,
      );
      return;
    }
    if (widget.onOpenEdit != null) {
      widget.onOpenEdit!(_currentCase);
      return;
    }
    final updated = await Navigator.push<CaseRecordModel>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahKasusScreen(initialCase: _currentCase),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentCase = updated;
      });
      ToastNotification.show(
        context,
        message: 'Berhasil: Data kasus ${_currentCase.id} telah diperbarui.',
        type: ToastType.success,
      );
    }
  }

  void _toggleStatus() {
    if (_isReadOnly) {
      ToastNotification.show(
        context,
        message:
            'Akses ditolak: Kepala Sekolah hanya memiliki izin melihat riwayat kasus.',
        type: ToastType.error,
      );
      return;
    }
    setState(() {
      _currentCase = _currentCase.copyWith(
        isCompleted: !_currentCase.isCompleted,
      );
    });
    ToastNotification.show(
      context,
      message: _currentCase.isCompleted
          ? 'Status kasus telah diubah menjadi Selesai.'
          : 'Status kasus dibuka kembali (Dalam Proses).',
      type: ToastType.success,
    );
  }

  Future<void> _handleDelete() async {
    if (_isReadOnly) {
      ToastNotification.show(
        context,
        message:
            'Akses ditolak: Kepala Sekolah hanya memiliki izin melihat riwayat kasus.',
        type: ToastType.error,
      );
      return;
    }
    final confirmed = await DeleteDialog.show(
      context,
      title: 'Hapus Catatan Kasus?',
      message:
          'Apakah Anda yakin ingin menghapus data kasus ${_currentCase.id} secara permanen?',
    );

    if (confirmed == true && mounted) {
      Navigator.maybePop(context);
      ToastNotification.show(
        context,
        message: 'Laporan kasus ${_currentCase.id} telah dihapus.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _currentCase.isCompleted;

    final Color badgeBg =
        isCompleted ? AppColors.successBg : AppColors.warningBg;
    final Color badgeText =
        isCompleted ? AppColors.successText : AppColors.warningText;
    final String badgeLabel = isCompleted ? 'Selesai' : 'Dalam Proses';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _currentCase);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvasLightGray,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 20.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Upper Detail Kasus Wrapper
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                      Navigator.pop(context, _currentCase);
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
                                const Text(
                                  'Detail Kasus',
                                  style: AppTextStyles.topBarTitle,
                                ),
                                
                                const SizedBox(width: 40.0, height: 40.0),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14.0),

                          // Kartu Utama Detail Pelanggaran
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
                                  color: AppColors.shadowBase
                                      .withValues(alpha: 0.039),
                                  offset: const Offset(0, 8),
                                  blurRadius: 22.0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Status & Nomor Kasus Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 27.0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                        horizontal: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius:
                                            BorderRadius.circular(99.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        badgeLabel,
                                        style: AppTextStyles
                                            .captionSemibold11
                                            .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: badgeText,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3.0,
                                            horizontal: 7.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.errorSurface,
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            '+${_currentCase.violationPoints} Poin',
                                            style: AppTextStyles.badgeBold10
                                                .copyWith(
                                              color: AppColors.errorPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          _currentCase.id,
                                          style: AppTextStyles.captionSemibold11
                                              .copyWith(
                                            color: AppColors.textPlaceholder,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14.0),

                                // Judul Kasus Pelanggaran Besar
                                Text(
                                  _currentCase.caseTitle,
                                  style: AppTextStyles.detailHeroTitle,
                                ),
                                const SizedBox(height: 5.0),

                                // Siswa & Kelas Terkait
                                Text(
                                  'Siswa: ${_currentCase.studentName} • ${_currentCase.studentClass} (${_currentCase.studentNisn})',
                                  style: AppTextStyles.metaSemibold12.copyWith(
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 14.0),

                                // Detail Waktu & Lokasi Kejadian
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputSurfaceGray,
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(
                                      color: AppColors.borderSoft,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 15.0,
                                            color: AppColors.primaryNavy,
                                          ),
                                          const SizedBox(width: 9.0),
                                          Expanded(
                                            child: Text(
                                              'Waktu: ${_currentCase.incidentTime}',
                                              style:
                                                  AppTextStyles.metaSemibold12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 9.0),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 15.0,
                                            color: AppColors.primaryNavy,
                                          ),
                                          const SizedBox(width: 9.0),
                                          Expanded(
                                            child: Text(
                                              'Tempat: ${_currentCase.incidentLocation}',
                                              style:
                                                  AppTextStyles.metaSemibold12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14.0),

                                // Deskripsi Kronologi
                                const Text(
                                  'Kronologi Kejadian',
                                  style: AppTextStyles.cardTitle,
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  _currentCase.chronology,
                                  style: AppTextStyles.paragraph12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14.0),

                          // Card Catatan Tindak Lanjut & Penanganan Guru BK (SRS-F-009)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(
                                color: AppColors.borderBlueAccent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryNavy
                                      .withValues(alpha: 0.071),
                                  offset: const Offset(0, 6),
                                  blurRadius: 18.0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header Tindak Lanjut
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 36.0,
                                      height: 36.0,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryNavy,
                                        borderRadius:
                                            BorderRadius.circular(11.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.verified_user_outlined,
                                        size: 18.0,
                                        color: AppColors.pureWhite,
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
                                            'Catatan Penanganan Guru BK',
                                            style: AppTextStyles.cardTitle
                                                .copyWith(
                                              color: AppColors.primaryNavy,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            '${_currentCase.counselorName} • ${_currentCase.handlingDate}',
                                            style: AppTextStyles
                                                .captionSemibold11
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.0),

                                // Isi Penanganan
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.pureWhite,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Text(
                                    _currentCase.handling,
                                    style: AppTextStyles.paragraph12.copyWith(
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Tombol Aksi: Read-Only (Kepala Sekolah) vs Aksi Lengkap (Guru BK)
                          if (_isReadOnly) ...[
                            CustomButton.secondary(
                              label: 'Kembali',
                              leadingIcon: Icons.arrow_back_rounded,
                              height: 48.0,
                              borderRadius: 12.0,
                              onPressed: () {
                                if (widget.onBack != null) {
                                  widget.onBack!();
                                } else {
                                  Navigator.pop(context, _currentCase);
                                }
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton.secondary(
                                    label: 'Edit Kasus',
                                    leadingIcon: Icons.edit_outlined,
                                    height: 48.0,
                                    borderRadius: 12.0,
                                    onPressed: _handleEditCase,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: CustomButton(
                                    label: isCompleted
                                        ? 'Buka Kembali'
                                        : 'Tandai Selesai',
                                    variant: isCompleted
                                        ? CustomButtonVariant.outlineNeutral
                                        : CustomButtonVariant.primary,
                                    leadingIcon: isCompleted
                                        ? Icons.refresh_rounded
                                        : Icons.check_circle_outline_rounded,
                                    height: 48.0,
                                    borderRadius: 12.0,
                                    onPressed: _toggleStatus,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            CustomButton(
                              label: 'Hapus Catatan Kasus',
                              variant: CustomButtonVariant.danger,
                              leadingIcon: Icons.delete_outline_rounded,
                              height: 46.0,
                              borderRadius: 12.0,
                              onPressed: _handleDelete,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Home Indicator
                      Container(
                        width: 134.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: AppColors.borderMuted,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
