import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/animated_dialog.dart';

/// Modal Konfirmasi Hapus (17-modal-konfirmasi-hapus.png).
/// Menggunakan backdrop 50% (#00000080) dengan efek blur, kartu putih 337px r=24 memantul masuk,
/// serta Halo Ikon Hapus (#FEF2F2 / #FEE2E2 / #DC2626) dengan animasi pegas elastis.
class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const DeleteDialog({
    super.key,
    this.title = 'Hapus Data Siswa?',
    this.message =
        'Apakah Anda yakin? Data beserta riwayat kasus siswa ini akan dihapus permanen dan tidak dapat dikembalikan.',
    this.onCancel,
    this.onConfirm,
  });

  /// Menampilkan dialog konfirmasi hapus di atas layar aktif dengan animasi pop-up menarik.
  static Future<bool?> show(
    BuildContext context, {
    String title = 'Hapus Data Siswa?',
    String message =
        'Apakah Anda yakin? Data beserta riwayat kasus siswa ini akan dihapus permanen dan tidak dapat dikembalikan.',
  }) {
    return showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => DeleteDialog(
        title: title,
        message: message,
        onCancel: () => Navigator.of(ctx).pop(false),
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 337,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderNeutral, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x470F172A),
                  blurRadius: 36,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Halo Ikon Hapus dengan animasi pegas elastis
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
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.errorBg,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.errorBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 24,
                        color: AppColors.errorPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Copy Konfirmasi Hapus (gap: 8)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.topBarTitle.copyWith(letterSpacing: -0.2),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    height: 20 / 13,
                  ),
                ),
                const SizedBox(height: 18),

                // Baris Tombol Aksi Modal (height: 46, gap: 10)
                SizedBox(
                  height: 46,
                  child: Row(
                    children: [
                      // Tombol Sekunder - Batal
                      Expanded(
                        child: Material(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onCancel ??
                                () => Navigator.of(context).maybePop(false),
                            child: Container(
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderMuted,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: AppTextStyles.sectionHeader14.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Tombol Utama Merah - Hapus
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.errorPrimary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x38DC2626),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: onConfirm ??
                                  () => Navigator.of(context).maybePop(true),
                              child: Center(
                                child: Text(
                                  'Hapus',
                                  style: AppTextStyles.sectionHeader14.copyWith(
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Layar pratinjau penuh untuk 17-modal-konfirmasi-hapus.png.
class DeleteDialogScreen extends StatelessWidget {
  const DeleteDialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.modalBackdrop),
          const DeleteDialog(),
        ],
      ),
    );
  }
}
