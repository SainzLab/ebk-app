import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  danger,
  outlineNeutral,
}

/// Komponen Reusable Tombol Utama & Sekunder sesuai `01 • Design System`
/// pada `ebk_design.json`.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? leadingIcon;
  final double height;
  final double borderRadius;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.leadingIcon,
    this.height = 52.0,
    this.borderRadius = 14.0,
    this.fontSize,
    this.padding,
    this.isFullWidth = true,
  });

  /// Factory untuk Tombol Utama (Variant=Primary)
  const CustomButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.height = 52.0,
    this.borderRadius = 14.0,
    this.fontSize,
    this.padding,
    this.isFullWidth = true,
  }) : variant = CustomButtonVariant.primary;

  /// Factory untuk Tombol Sekunder (Variant=Secondary)
  const CustomButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.height = 50.0,
    this.borderRadius = 14.0,
    this.fontSize,
    this.padding,
    this.isFullWidth = true,
  }) : variant = CustomButtonVariant.secondary;

  /// Factory untuk Tombol Bahaya / Destruktif (Variant=Danger)
  const CustomButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.height = 50.0,
    this.borderRadius = 14.0,
    this.fontSize,
    this.padding,
    this.isFullWidth = true,
  }) : variant = CustomButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == CustomButtonVariant.primary;
    final bool isSecondary = variant == CustomButtonVariant.secondary;
    final bool isDanger = variant == CustomButtonVariant.danger;

    final Color backgroundColor = switch (variant) {
      CustomButtonVariant.primary => AppColors.primaryNavy,
      CustomButtonVariant.secondary => AppColors.pureWhite,
      CustomButtonVariant.danger => AppColors.errorPrimary,
      CustomButtonVariant.outlineNeutral => AppColors.pureWhite,
    };

    final Color foregroundColor = switch (variant) {
      CustomButtonVariant.primary => AppColors.pureWhite,
      CustomButtonVariant.secondary => AppColors.primaryNavy,
      CustomButtonVariant.danger => AppColors.pureWhite,
      CustomButtonVariant.outlineNeutral => AppColors.textSecondary,
    };

    final Border? border = switch (variant) {
      CustomButtonVariant.primary => null,
      CustomButtonVariant.secondary => Border.all(
          color: AppColors.primaryNavy,
          width: 1.5,
        ),
      CustomButtonVariant.danger => null,
      CustomButtonVariant.outlineNeutral => Border.all(
          color: AppColors.borderMuted,
          width: 1.2,
        ),
    };

    final List<BoxShadow>? boxShadow = switch (variant) {
      CustomButtonVariant.primary => [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.20),
            offset: const Offset(0, 6),
            blurRadius: 16.0,
          ),
        ],
      CustomButtonVariant.danger => [
          BoxShadow(
            color: AppColors.errorPrimary.withValues(alpha: 0.22),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
          ),
        ],
      _ => null,
    };

    final TextStyle textStyle = isPrimary
        ? AppTextStyles.button.copyWith(fontSize: fontSize ?? 16.0)
        : isSecondary
            ? AppTextStyles.buttonSecondary.copyWith(
                fontSize: fontSize ?? 15.0,
                fontWeight:
                    leadingIcon != null ? FontWeight.w700 : FontWeight.w600,
              )
            : TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: fontSize ?? 14.0,
                height: 20.0 / (fontSize ?? 14.0),
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              );

    return Container(
      width: isFullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: isPrimary || isDanger
              ? AppColors.pureWhite.withValues(alpha: 0.12)
              : AppColors.primaryTint,
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: isSecondary ? 20.0 : 24.0,
                ),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    size: 18.0,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: 10.0),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Kontainer Sticky Action Bar di bagian bawah layar form/detail
/// sesuai `Bottom Action Bar` pada `ebk_design.json` (padding: [14, 20, 10, 20]).
class CustomBottomActionBar extends StatelessWidget {
  final Widget child;
  final bool showHomeIndicator;

  const CustomBottomActionBar({
    super.key,
    required this.child,
    this.showHomeIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 10.0),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: const Border(
          top: BorderSide(color: AppColors.borderNeutral, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.039),
            offset: const Offset(0, -4),
            blurRadius: 16.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (showHomeIndicator) ...[
            const SizedBox(height: 12.0),
            Container(
              width: 134.0,
              height: 5.0,
              decoration: BoxDecoration(
                color: AppColors.borderMuted,
                borderRadius: BorderRadius.circular(99.0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
