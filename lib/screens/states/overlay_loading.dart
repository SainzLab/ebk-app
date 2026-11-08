import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/animated_dialog.dart';

/// Overlay Loading State (15-overlay-loading-state.png).
/// Menampilkan backdrop hitam 40% (#00000066) dan Card Loading Modal (236x169, r=24)
/// dengan Navy Loading Spinner (48x48, stroke 5px) sesuai ebk_design.json.
class OverlayLoading extends StatefulWidget {
  final String title;
  final String subtitle;

  const OverlayLoading({
    super.key,
    this.title = 'Memproses data...',
    this.subtitle = 'Mohon tunggu sebentar',
  });

  /// Menampilkan modal loading di atas layar aktif.
  static Future<void> show(
    BuildContext context, {
    String title = 'Memproses data...',
    String subtitle = 'Mohon tunggu sebentar',
  }) {
    return showAnimatedDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.overlayBackdrop,
      builder: (_) => OverlayLoading(title: title, subtitle: subtitle),
    );
  }

  @override
  State<OverlayLoading> createState() => _OverlayLoadingState();
}

class _OverlayLoadingState extends State<OverlayLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 236,
          height: 169,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderNeutral, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x380F172A),
                blurRadius: 34,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Navy Loading Spinner (56x56 container, 48x48 ring)
              SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: _spinController.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(48, 48),
                          painter: _NavySpinnerPainter(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Loading Copy Group (gap: 4)
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionHeader15,
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavySpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(strokeWidth / 2);

    final trackPaint = Paint()
      ..color = AppColors.primaryTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final activePaint = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(insetRect, trackPaint);
    canvas.drawArc(
      insetRect,
      -math.pi / 2,
      math.pi * 0.65,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Layar pratinjau penuh 15-overlay-loading-state.png dengan latar belakang
/// form "Catat Kasus Baru" yang sedang diproses.
class OverlayLoadingScreen extends StatelessWidget {
  const OverlayLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Context - Catat Kasus Baru (In Progress)
          SafeArea(
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.pureWhite,
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderSoft),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.canvasLightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Catat Kasus Baru',
                        style: AppTextStyles.greetingActor.copyWith(
                          letterSpacing: -0.2,
                          height: 22 / 17,
                        ),
                      ),
                      const SizedBox(width: 38, height: 38),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReadOnlyField(
                            label: 'Pilih Siswa',
                            value: 'Ahmad Fauzi — Kelas 8A (0084921034)',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildReadOnlyField(
                            label: 'Kategori Kasus',
                            value: 'Kedisiplinan',
                            icon: Icons.folder_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildReadOnlyField(
                            label: 'Tanggal Kejadian',
                            value: '17 Agustus 2026',
                            icon: Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Deskripsi Kejadian / Masalah',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 106,
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.inputSurfaceGray,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderMuted),
                            ),
                            child: Text(
                              'Siswa terlambat masuk sekolah lebih dari 30 menit sebanyak 3 kali berturut-turut dalam minggu ini tanpa keterangan resmi dari orang tua.',
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w400,
                                height: 20 / 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dark Backdrop 40% + Modal Card
          Container(
            color: AppColors.overlayBackdrop,
            child: const OverlayLoading(),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(width: 2),
            Text(
              '*',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.errorPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.inputSurfaceGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderMuted),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryNavy),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
