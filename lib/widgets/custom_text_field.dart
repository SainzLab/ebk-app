import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Komponen Reusable Input Field (Default, Focused, Password, Select/Dropdown,
/// dan TextArea) sesuai `ebk_design.json`.
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? rightLabel;
  final String hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onTap;
  final bool isPassword;
  final bool readOnly;
  final int maxLines;
  final int? maxLengthCounter;
  final double? containerHeight;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double labelGap;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    this.label,
    this.rightLabel,
    required this.hintText,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.onSuffixTap,
    this.onTap,
    this.isPassword = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLengthCounter,
    this.containerHeight,
    this.borderRadius = 14.0,
    this.contentPadding,
    this.labelStyle,
    this.textStyle,
    this.hintStyle,
    this.labelGap = 8.0,
    this.onChanged,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  late final TextEditingController _internalController;
  bool _obscureText = true;
  bool _isFocused = false;
  int _charCount = 0;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode()
      ..addListener(() {
        if (mounted) {
          setState(() {
            _isFocused = _focusNode.hasFocus;
          });
        }
      });
    _internalController = TextEditingController(text: widget.initialValue ?? '');
    _charCount = _effectiveController.text.length;
    _effectiveController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (mounted && widget.maxLengthCounter != null) {
      setState(() {
        _charCount = _effectiveController.text.length;
      });
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = widget.maxLines > 1;
    final double resolvedHeight = widget.containerHeight ??
        (isMultiline ? 132.0 : 50.0);

    final Color fillColor = _isFocused
        ? AppColors.pureWhite
        : AppColors.inputSurfaceGray;

    final Color borderColor = _isFocused
        ? AppColors.primaryNavy
        : AppColors.borderNeutral;

    final double borderWidth = _isFocused ? 1.5 : 1.0;

    final Color resolvedPrefixColor = _isFocused
        ? AppColors.primaryNavy
        : (widget.prefixIconColor ?? AppColors.textMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label!,
                style: widget.labelStyle ?? AppTextStyles.label,
              ),
              if (widget.rightLabel != null)
                Text(
                  widget.rightLabel!,
                  style: AppTextStyles.subtitle11,
                ),
            ],
          ),
          SizedBox(height: widget.labelGap),
        ],
        GestureDetector(
          onTap: widget.readOnly ? widget.onTap : () => _focusNode.requestFocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            height: resolvedHeight,
            padding: widget.contentPadding ??
                (isMultiline
                    ? const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0)
                    : const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      )),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: isMultiline
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _effectiveController,
                          focusNode: _focusNode,
                          readOnly: widget.readOnly,
                          onTap: widget.onTap,
                          onChanged: widget.onChanged,
                          maxLines: widget.maxLines,
                          keyboardType:
                              widget.keyboardType ?? TextInputType.multiline,
                          style: widget.textStyle ??
                              const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13.0,
                                height: 19.0 / 13.0,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: widget.hintText,
                            hintStyle: widget.hintStyle ??
                                const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13.0,
                                  height: 19.0 / 13.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPlaceholder,
                                ),
                          ),
                        ),
                      ),
                      if (widget.maxLengthCounter != null)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '$_charCount / ${widget.maxLengthCounter} karakter',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10.0,
                              height: 14.0 / 10.0,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPlaceholder,
                            ),
                          ),
                        ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Icon(
                          widget.prefixIcon,
                          size: 18.0,
                          color: resolvedPrefixColor,
                        ),
                        const SizedBox(width: 12.0),
                      ],
                      Expanded(
                        child: IgnorePointer(
                          ignoring: widget.readOnly && widget.onTap != null,
                          child: TextField(
                            controller: _effectiveController,
                            focusNode: _focusNode,
                            readOnly: widget.readOnly,
                            obscureText: widget.isPassword && _obscureText,
                            onChanged: widget.onChanged,
                            keyboardType: widget.keyboardType,
                            style: widget.textStyle ??
                                const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14.0,
                                  height: 20.0 / 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: widget.hintText,
                              hintStyle: widget.hintStyle ??
                                  const TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14.0,
                                    height: 20.0 / 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textMuted,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.isPassword) ...[
                        const SizedBox(width: 12.0),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18.0,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ] else if (widget.suffixIcon != null) ...[
                        const SizedBox(width: 10.0),
                        GestureDetector(
                          onTap: widget.onSuffixTap ?? widget.onTap,
                          child: Icon(
                            widget.suffixIcon,
                            size: 18.0,
                            color: widget.suffixIconColor ?? AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
