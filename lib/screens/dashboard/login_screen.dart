import 'package:flutter/material.dart';
import '../../core/app_exception.dart';
import '../../core/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast_notification.dart';

/// Halaman Login (`02 • Layar Login (SRS-F-001)`)
/// berdasarkan `02-layar-login-srs-f-001.png` dan `ebk_design.json`.
class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onHelpTap;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onForgotPassword,
    this.onHelpTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
      return;
    }

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ToastNotification.show(
        context,
        message: 'Harap masukkan Email/Username dan Kata Sandi.',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final role = await AuthService.instance.login(
        identifier: identifier,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AuthService.routeForRole(role));
    } on AppException catch (e) {
      if (!mounted) return;
      ToastNotification.show(
        context,
        message: e.message,
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 26.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top & Form Stack (gap: 24.0)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Identitas Aplikasi E-BK (pad: [12, 8, 4, 8], gap: 14)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 4.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo Halo (76x76, r=24, fill=#EBF2FF, stroke=#DBEAFE)
                              Container(
                                width: 76.0,
                                height: 76.0,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: AppColors.borderBlueTint,
                                    width: 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  width: 58.0,
                                  height: 58.0,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavy,
                                    borderRadius: BorderRadius.circular(18.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryNavy
                                            .withValues(alpha: 0.22),
                                        offset: const Offset(0, 6),
                                        blurRadius: 14.0,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const CustomPaint(
                                    size: Size(28.0, 34.0),
                                    painter: _ShieldBookEmblemPainter(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14.0),
                              // Header & Sambutan Text (gap: 6.0)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Pill Layanan
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 12.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTint,
                                      borderRadius: BorderRadius.circular(99.0),
                                    ),
                                    child: const Text(
                                      'BIMBINGAN & KONSELING SISWA',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  const Text(
                                    'E-BK SMPN 1 Pabuaran',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.heading1,
                                  ),
                                  const SizedBox(height: 6.0),
                                  const Text(
                                    'Silakan masuk ke akun Anda',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // Kartu Form Login (r=24, fill=#FFFFFF, stroke=#EEF2F6, pad=[24, 20], gap=20)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24.0,
                            horizontal: 20.0,
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
                                    .withValues(alpha: 0.051),
                                offset: const Offset(0, 10),
                                blurRadius: 28.0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Inputs Stack (gap: 16.0)
                              CustomTextField(
                                label: 'Email / NISN',
                                hintText: 'Masukkan Email atau NISN',
                                controller: _identifierController,
                                prefixIcon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16.0),
                              CustomTextField(
                                label: 'Kata Sandi',
                                hintText: 'Masukkan kata sandi',
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                              ),
                              const SizedBox(height: 16.0),
                              // Lupa Kata Sandi Row
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: widget.onForgotPassword,
                                  child: const Text(
                                    'Lupa Kata Sandi?',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13.0,
                                      height: 18.0 / 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              // Tombol Utama Login
                              CustomButton.primary(
                                label: _isSubmitting ? 'Memproses...' : 'Login',
                                onPressed: _isSubmitting ? null : _handleLogin,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    // Footer Area (gap: 16.0)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Kartu Bantuan Guru BK (height: 60, r=16, pad=[12, 16], gap=12)
                        GestureDetector(
                          onTap: widget.onHelpTap,
                          child: Container(
                            width: double.infinity,
                            height: 60.0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: AppColors.borderNeutral,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 34.0,
                                  height: 34.0,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'BK',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                const Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kendala masuk ke akun siswa?',
                                        style: AppTextStyles.metaSemibold12,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.0),
                                      Text(
                                        'Hubungi Ruang Guru BK SMPN 1 Pabuaran',
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
                        ),
                        const SizedBox(height: 16.0),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom Painter untuk menggambar Emblem Shield + Buku Terbuka
/// sesuai vektor `Logo Emblem Navy` pada `02 • Layar Login (SRS-F-001)`.
class _ShieldBookEmblemPainter extends CustomPainter {
  const _ShieldBookEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path shieldPath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.16)
      ..lineTo(w, h * 0.50)
      ..cubicTo(w, h * 0.76, w * 0.74, h * 0.92, w * 0.5, h)
      ..cubicTo(w * 0.26, h * 0.92, 0, h * 0.76, 0, h * 0.50)
      ..lineTo(0, h * 0.16)
      ..close();

    final Paint fillPaint = Paint()
      ..color = AppColors.pureWhite.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = AppColors.pureWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(shieldPath, fillPaint);
    canvas.drawPath(shieldPath, strokePaint);

    // Open Book Vector inside shield
    final Paint bookPaint = Paint()
      ..color = AppColors.pureWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double bx = w * 0.22;
    final double by = h * 0.34;
    final double bw = w * 0.56;
    final double bh = h * 0.30;

    final Path leftPage = Path()
      ..moveTo(w * 0.5, by + 2.0)
      ..cubicTo(w * 0.40, by - 1.0, bx + 2.0, by - 1.0, bx, by + 1.5)
      ..lineTo(bx, by + bh)
      ..cubicTo(bx + 2.0, by + bh - 2.0, w * 0.40, by + bh - 2.0, w * 0.5,
          by + bh + 1.0);

    final Path rightPage = Path()
      ..moveTo(w * 0.5, by + 2.0)
      ..cubicTo(w * 0.60, by - 1.0, bx + bw - 2.0, by - 1.0, bx + bw, by + 1.5)
      ..lineTo(bx + bw, by + bh)
      ..cubicTo(bx + bw - 2.0, by + bh - 2.0, w * 0.60, by + bh - 2.0, w * 0.5,
          by + bh + 1.0);

    canvas.drawPath(leftPage, bookPaint);
    canvas.drawPath(rightPage, bookPaint);
    canvas.drawLine(
      Offset(w * 0.5, by + 2.0),
      Offset(w * 0.5, by + bh + 1.0),
      bookPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
