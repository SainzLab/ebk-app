import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/animated_dialog.dart';

/// Modal Peringatan Sistem - Sesi Berakhir (18-modal-peringatan-sistem.png).
/// Menampilkan backdrop gelap 50% (#00000080) dengan efek blur, Halo Ikon Peringatan (#FFFBEB / #FEF3C7 / #D97706)
/// dengan animasi pegas elastis, serta tombol penuh "Login Ulang" (#1B3B7B).
class SessionDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRelogin;

  const SessionDialog({
    super.key,
    this.title = 'Sesi Berakhir',
    this.message =
        'Sesi login Anda telah habis karena tidak ada aktivitas. Silakan login kembali untuk melanjutkan.',
    this.onRelogin,
  });

  /// Menampilkan modal sesi berakhir di atas layar aktif dengan animasi pop-up menarik.
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRelogin,
  }) {
    return showAnimatedDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SessionDialog(
        onRelogin: onRelogin ??
            () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
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
                // Halo Ikon Peringatan dengan animasi pegas elastis
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
                      color: AppColors.warningSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.warningBg,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.warningBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 24,
                        color: AppColors.warningIcon,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Copy Sesi Berakhir (gap: 8)
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

                // Tombol Utama Navy - Login Ulang (height: 46, r: 12)
                Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x331B3B7B),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onRelogin ??
                          () {
                            Navigator.of(context).maybePop();
                          },
                      child: Center(
                        child: Text(
                          'Login Ulang',
                          style: AppTextStyles.sectionHeader14.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ),
                    ),
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

/// Layar pratinjau penuh untuk 18-modal-peringatan-sistem.png.
class SessionDialogScreen extends StatelessWidget {
  const SessionDialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.modalBackdrop),
          const SessionDialog(),
        ],
      ),
    );
  }
}
