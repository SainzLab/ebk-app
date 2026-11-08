import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Helper reusable untuk menampilkan Dialog/Pop-Up dengan animasi yang menarik:
/// - Latar belakang gelap dengan efek frosted glass / blur (BackdropFilter)
/// - Kartu dialog memantul masuk dengan kurva spring (Curves.easeOutBack) & Fade
/// - Menghasilkan transisi yang mulus, dinamis, dan modern pada seluruh modal aplikasi.
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  Duration duration = const Duration(milliseconds: 320),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Modal',
    barrierColor: barrierColor ?? AppColors.modalBackdrop,
    transitionDuration: duration,
    pageBuilder: (dialogCtx, anim1, anim2) => builder(dialogCtx),
    transitionBuilder: (dialogCtx, anim1, anim2, child) {
      final curvedValue = Curves.easeOutBack.transform(anim1.value);
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0 * anim1.value,
          sigmaY: 5.0 * anim1.value,
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOut,
          ),
          child: Transform.scale(
            scale: 0.82 + (0.18 * curvedValue),
            child: child,
          ),
        ),
      );
    },
  );
}
