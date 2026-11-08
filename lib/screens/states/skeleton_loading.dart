import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Skeleton Loading State (14-skeleton-loading-state.png).
/// Merepresentasikan state pemuatan awal Dashboard Guru BK dengan efek shimmer
/// linear gradient (#DCE3EE -> #EEF3F9 -> #DCE3EE) sesuai spesifikasi ebk_design.json.
class SkeletonLoading extends StatefulWidget {
  const SkeletonLoading({super.key});

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, _) {
            final slide = (_shimmerController.value * 2) - 1;
            final gradient = LinearGradient(
              begin: Alignment(-1.0 + slide, 0.0),
              end: Alignment(1.0 + slide, 0.0),
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Skeleton Top Bar (height: 48, gap: 12)
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              _SkeletonBone(
                                width: 44,
                                height: 44,
                                borderRadius: 99,
                                gradient: gradient,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SkeletonBone(
                                      width: 104,
                                      height: 10,
                                      borderRadius: 5,
                                      gradient: gradient,
                                    ),
                                    const SizedBox(height: 6),
                                    _SkeletonBone(
                                      width: 138,
                                      height: 18,
                                      borderRadius: 7,
                                      gradient: gradient,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 82,
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.skeletonCardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _SkeletonBone(
                                      width: 14,
                                      height: 14,
                                      borderRadius: 99,
                                      gradient: gradient,
                                    ),
                                    const SizedBox(width: 6),
                                    _SkeletonBone(
                                      width: 36,
                                      height: 10,
                                      borderRadius: 5,
                                      gradient: gradient,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 2. Skeleton Card Ringkasan Cepat (height: 172, r: 24, padding: 18)
                        Container(
                          height: 172,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.borderNeutral,
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F0F172A),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _SkeletonBone(
                                    width: 108,
                                    height: 13,
                                    borderRadius: 6,
                                    gradient: gradient,
                                  ),
                                  _SkeletonBone(
                                    width: 98,
                                    height: 22,
                                    borderRadius: 99,
                                    gradient: gradient,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 98,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.inputSurfaceGray,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color:
                                                AppColors.skeletonSubcardBorder,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _SkeletonBone(
                                                  width: 46,
                                                  height: 26,
                                                  borderRadius: 8,
                                                  gradient: gradient,
                                                ),
                                                _SkeletonBone(
                                                  width: 30,
                                                  height: 30,
                                                  borderRadius: 99,
                                                  gradient: gradient,
                                                ),
                                              ],
                                            ),
                                            _SkeletonBone(
                                              width: 94,
                                              height: 11,
                                              borderRadius: 5,
                                              gradient: gradient,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.inputSurfaceGray,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color:
                                                AppColors.skeletonSubcardBorder,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _SkeletonBone(
                                                  width: 46,
                                                  height: 26,
                                                  borderRadius: 8,
                                                  gradient: gradient,
                                                ),
                                                _SkeletonBone(
                                                  width: 30,
                                                  height: 30,
                                                  borderRadius: 99,
                                                  gradient: gradient,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _SkeletonBone(
                                                  width: 112,
                                                  height: 11,
                                                  borderRadius: 5,
                                                  gradient: gradient,
                                                ),
                                                const SizedBox(height: 5),
                                                _SkeletonBone(
                                                  width: 68,
                                                  height: 9,
                                                  borderRadius: 4,
                                                  gradient: gradient,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 3. Skeleton Menu Section (gap: 12)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SkeletonBone(
                              width: 132,
                              height: 16,
                              borderRadius: 6,
                              gradient: gradient,
                            ),
                            _SkeletonBone(
                              width: 68,
                              height: 12,
                              borderRadius: 5,
                              gradient: gradient,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Menu Row 1 (height: 122, gap: 12)
                        SizedBox(
                          height: 122,
                          child: Row(
                            children: [
                              Expanded(
                                child: _SkeletonMenuCard(
                                  gradient: gradient,
                                  titleWidth: 88,
                                  subWidth: 114,
                                  showRightBadge: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SkeletonMenuCard(
                                  gradient: gradient,
                                  titleWidth: 84,
                                  subWidth: 120,
                                  showRightBadge: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Menu Row 2 (height: 132, gap: 12)
                        SizedBox(
                          height: 132,
                          child: Row(
                            children: [
                              Expanded(
                                child: _SkeletonMenuCard(
                                  gradient: gradient,
                                  titleWidth: 122,
                                  subWidth: 116,
                                  showRightBadge: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SkeletonMenuCard(
                                  gradient: gradient,
                                  titleWidth: 118,
                                  secondTitleWidth: 62,
                                  subWidth: 112,
                                  showRightBadge: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Menu Row 3 - Wide Card (height: 70, r: 20, padding: [13, 15])
                        Container(
                          height: 70,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.skeletonCardBorder,
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A0F172A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _SkeletonBone(
                                width: 42,
                                height: 42,
                                borderRadius: 99,
                                gradient: gradient,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SkeletonBone(
                                      width: 118,
                                      height: 14,
                                      borderRadius: 6,
                                      gradient: gradient,
                                    ),
                                    const SizedBox(height: 6),
                                    _SkeletonBone(
                                      width: 136,
                                      height: 10,
                                      borderRadius: 4,
                                      gradient: gradient,
                                    ),
                                  ],
                                ),
                              ),
                              _SkeletonBone(
                                width: 66,
                                height: 22,
                                borderRadius: 99,
                                gradient: gradient,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Skeleton Bottom Navigation Bar (height: 73, padding: [10, 12, 8, 12])
                Container(
                  height: 73,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  decoration: const BoxDecoration(
                    color: AppColors.pureWhite,
                    border: Border(
                      top: BorderSide(color: AppColors.borderNeutral, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SkeletonNavTab(
                              iconWidth: 44,
                              gradient: gradient,
                            ),
                            _SkeletonNavTab(
                              iconWidth: 24,
                              gradient: gradient,
                            ),
                            _SkeletonNavTab(
                              iconWidth: 24,
                              gradient: gradient,
                            ),
                            _SkeletonNavTab(
                              iconWidth: 24,
                              gradient: gradient,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderMuted,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkeletonBone extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final LinearGradient gradient;

  const _SkeletonBone({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _SkeletonMenuCard extends StatelessWidget {
  final LinearGradient gradient;
  final double titleWidth;
  final double? secondTitleWidth;
  final double subWidth;
  final bool showRightBadge;

  const _SkeletonMenuCard({
    required this.gradient,
    required this.titleWidth,
    this.secondTitleWidth,
    required this.subWidth,
    required this.showRightBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.skeletonCardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SkeletonBone(
                width: 42,
                height: 42,
                borderRadius: 99,
                gradient: gradient,
              ),
              if (showRightBadge)
                _SkeletonBone(
                  width: 56,
                  height: 20,
                  borderRadius: 99,
                  gradient: gradient,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBone(
                width: titleWidth,
                height: 14,
                borderRadius: 6,
                gradient: gradient,
              ),
              if (secondTitleWidth != null) ...[
                const SizedBox(height: 5),
                _SkeletonBone(
                  width: secondTitleWidth!,
                  height: 14,
                  borderRadius: 6,
                  gradient: gradient,
                ),
              ],
              const SizedBox(height: 6),
              _SkeletonBone(
                width: subWidth,
                height: 10,
                borderRadius: 4,
                gradient: gradient,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonNavTab extends StatelessWidget {
  final double iconWidth;
  final LinearGradient gradient;

  const _SkeletonNavTab({
    required this.iconWidth,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SkeletonBone(
            width: iconWidth,
            height: 24,
            borderRadius: 99,
            gradient: gradient,
          ),
          const SizedBox(height: 5),
          _SkeletonBone(
            width: 38,
            height: 8,
            borderRadius: 4,
            gradient: gradient,
          ),
        ],
      ),
    );
  }
}
