import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ToastType {
  success,
  error,
}

/// Komponen Reusable Notifikasi Toast (`16 • Komponen Notifikasi (Toast)`)
/// sesuai `ebk_design.json` (Toast Sukses & Toast Error/Gagal).
/// Dilengkapi animasi kemunculan pegas (spring entrance), ikon berdenyut (elastic pop),
/// bilah progres hitung mundur (countdown progress bar), serta interaksi swipe-to-dismiss.
class ToastNotification extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onClose;
  final Duration duration;
  final bool animateEntry;

  const ToastNotification({
    super.key,
    required this.message,
    this.type = ToastType.success,
    this.onClose,
    this.duration = const Duration(seconds: 3),
    this.animateEntry = true,
  });

  /// Varian 01 • Toast Sukses (Success Snackbar)
  const ToastNotification.success({
    super.key,
    this.message = 'Berhasil: Data kasus baru telah disimpan.',
    this.onClose,
    this.duration = const Duration(seconds: 3),
    this.animateEntry = false,
  }) : type = ToastType.success;

  /// Varian 02 • Toast Error / Gagal (Error Snackbar)
  const ToastNotification.error({
    super.key,
    this.message = 'Gagal: NISN tidak ditemukan atau koneksi terputus.',
    this.onClose,
    this.duration = const Duration(seconds: 3),
    this.animateEntry = false,
  }) : type = ToastType.error;

  /// Helper untuk menampilkan ToastNotification sebagai SnackBar mengambang dengan animasi
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        padding: EdgeInsets.zero,
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        content: ToastNotification(
          message: message,
          type: type,
          duration: duration,
          animateEntry: true,
          onClose: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  @override
  State<ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _iconAnimation;
  AnimationController? _progressController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _iconAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.18, 1.0, curve: Curves.elasticOut),
    );

    if (widget.animateEntry) {
      _entryController.forward();

      _progressController = AnimationController(
        vsync: this,
        duration: widget.duration,
      )..reverse(from: 1.0);
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _progressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = widget.type == ToastType.success;

    final Color bgColor =
        isSuccess ? AppColors.successBg : AppColors.errorBg;
    final Color borderColor =
        isSuccess ? AppColors.successBorder : AppColors.errorBorder;
    final Color badgeColor =
        isSuccess ? AppColors.successBadgeBg : AppColors.errorBadgeBg;
    final Color iconColor =
        isSuccess ? AppColors.successDarkText : AppColors.errorIcon;
    final Color textColor =
        isSuccess ? AppColors.successDarkText : AppColors.errorDarkText;
    final Color closeColor =
        isSuccess ? AppColors.successText : AppColors.errorClose;
    final Color shadowColor = isSuccess
        ? const Color(0xFF14532D).withValues(alpha: 0.08)
        : const Color(0xFF7F1D1D).withValues(alpha: 0.08);
    final Color progressColor =
        isSuccess ? AppColors.successDarkText : AppColors.errorIcon;

    final cardContent = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 68.4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 6),
            blurRadius: 16.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: widget.animateEntry
                              ? _iconAnimation
                              : const AlwaysStoppedAnimation(1.0),
                          child: Container(
                            width: 34.0,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isSuccess
                                  ? Icons.check_rounded
                                  : Icons.warning_amber_rounded,
                              size: 18.0,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13.0,
                              height: 19.0 / 13.0,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  GestureDetector(
                    onTap: widget.onClose,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.0,
                        color: closeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_progressController != null)
              AnimatedBuilder(
                animation: _progressController!,
                builder: (context, _) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _progressController!.value.clamp(0.0, 1.0),
                      child: Container(
                        height: 3.0,
                        color: progressColor.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );

    if (!widget.animateEntry) {
      return cardContent;
    }

    return Dismissible(
      key: const ValueKey('toast_dismissible'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => widget.onClose?.call(),
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: cardContent,
          ),
        ),
      ),
    );
  }
}

/// Kartu Showcase Komponen Notifikasi (Toast) sesuai Gambar 16
/// (`16-komponen-notifikasi-toast.png` / Page 15 `ebk_design.json`).
class ToastNotificationShowcaseCard extends StatelessWidget {
  const ToastNotificationShowcaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 433.0,
      padding: const EdgeInsets.fromLTRB(40.0, 32.0, 40.0, 36.0),
      decoration: BoxDecoration(
        color: AppColors.canvasLightGray,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: AppColors.borderMuted,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.071),
            offset: const Offset(0, 10),
            blurRadius: 28.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Komponen Toast
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(99.0),
              border: Border.all(
                color: AppColors.borderBlueAccent,
                width: 1.0,
              ),
            ),
            child: const Text(
              'MOBILE SNACKBAR • AUTO-LAYOUT',
              style: AppTextStyles.badgeBold10,
            ),
          ),
          const SizedBox(height: 6.0),
          const Text(
            'Komponen Notifikasi (Toast)',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 20.0,
              height: 26.0 / 20.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          const Text(
            'Umpan balik instan (Snackbar) dengan sudut membulat untuk aksi berhasil maupun kendala sistem pada layar mobile E-BK.',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.0,
              height: 18.0 / 12.0,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 22.0),
          Container(
            width: double.infinity,
            height: 1.0,
            color: AppColors.borderNeutral,
          ),
          const SizedBox(height: 22.0),
          // Varian 01 - Toast Sukses
          const Text(
            '01 • Toast Sukses (Success Snackbar)',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.0,
              height: 15.0 / 11.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          const ToastNotification.success(),
          const SizedBox(height: 22.0),
          // Varian 02 - Toast Error
          const Text(
            '02 • Toast Error / Gagal (Error Snackbar)',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.0,
              height: 15.0 / 11.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),
          const ToastNotification.error(),
        ],
      ),
    );
  }
}
