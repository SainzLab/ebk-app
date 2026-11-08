import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sumber kebenaran mutlak (Single Source of Truth) untuk tipografi Inter
/// yang diekstrak langsung dari `ebk_design.json` (E-BK SMPN 1 Pabuaran).
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // ===========================================================================
  // 01. Master Text Styles (S:9 - S:14 di ebk_design.json)
  // ===========================================================================

  /// S:9 - Heading 1 • Inter Bold 22/30 (#0F172A)
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    height: 30.0 / 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// S:10 - Heading 2 • Inter Bold 18/26 (#0F172A)
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    height: 26.0 / 18.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// S:11 - Body • Inter Regular 14/20 (#64748B)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: AppColors.textMuted,
  );

  /// S:12 - Label • Inter SemiBold 13/18 (#0F172A)
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    height: 18.0 / 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  /// S:13 - Button • Inter Bold 16/24 (#FFFFFF)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    height: 22.0 / 16.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    color: AppColors.pureWhite,
  );

  /// Button Secondary • Inter SemiBold 15/22 (#1B3B7B)
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    height: 22.0 / 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    color: AppColors.primaryNavy,
  );

  /// S:14 - Caption • Inter Regular 12/16 (#64748B)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: AppColors.textMuted,
  );

  // ===========================================================================
  // 02. Screen-Specific Typography Tokens dari ebk_design.json
  // ===========================================================================

  /// Top Bar Title • Inter Bold 18/24 (#0F172A)
  static const TextStyle topBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    height: 24.0 / 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Greeting Guru BK • Inter Bold 19/25 (#0F172A)
  static const TextStyle greetingGuru = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19.0,
    height: 25.0 / 19.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Greeting Ortu / Kepsek • Inter Bold 17/23 (#0F172A)
  static const TextStyle greetingActor = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    height: 23.0 / 17.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Detail Kasus Main Title • Inter Bold 20/27 (#0F172A)
  static const TextStyle detailHeroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    height: 27.0 / 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Section Header • Inter Bold 16/22 (#0F172A)
  static const TextStyle sectionHeader16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    height: 22.0 / 16.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Section Header • Inter Bold 15/21 (#0F172A)
  static const TextStyle sectionHeader15 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    height: 21.0 / 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Section Header • Inter Bold 14/20 (#0F172A)
  static const TextStyle sectionHeader14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Card Title • Inter Bold 13/18 (#0F172A)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    height: 18.0 / 13.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Sub-label / Meta • Inter SemiBold 12/16 (#0F172A)
  static const TextStyle metaSemibold12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Paragraph 12/18 • Inter Regular 12/18 (#475569)
  static const TextStyle paragraph12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    height: 18.0 / 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Body Text 12 • Inter Regular 12/18 (#475569)
  static const TextStyle bodyText12 = paragraph12;

  /// Small Body 11/16 • Inter Regular 11/16 (#475569)
  static const TextStyle bodySmall11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    height: 16.0 / 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Small Subtitle 11/15 • Inter Regular 11/15 (#64748B)
  static const TextStyle subtitle11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    height: 15.0 / 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  /// Small SemiBold 11/15 • Inter SemiBold 11/15 (#64748B)
  static const TextStyle captionSemibold11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    height: 15.0 / 11.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  /// Pill / Badge Text • Inter SemiBold 10/14 (#1B3B7B)
  static const TextStyle badgeSemibold10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    height: 14.0 / 10.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryNavy,
  );

  /// Pill / Badge Bold • Inter Bold 10/14 (#1B3B7B)
  static const TextStyle badgeBold10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    height: 14.0 / 10.0,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryNavy,
  );
}
