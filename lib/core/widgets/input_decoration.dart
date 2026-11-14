import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/core/constants/app_colors.dart';

InputDecoration inputDecoration({
  String? hint,
  String? labelText,
  String? helperText,
  Widget? suffixIcon,
  Widget? prefixIcon,
  bool isDense = false,
  Color? prefixIconColor,
  Color? fillColor,
  Color? borderColor,
  double borderRadius = 14.0,
  EdgeInsetsGeometry? contentPadding,
}) {
  OutlineInputBorder outlineInputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppColors.textTertiary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelText: labelText,
    labelStyle: const TextStyle(
      color: AppColors.greyText,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.primary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    helperText: helperText,
    helperMaxLines: 2,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixIconColor: prefixIconColor ?? AppColors.greyText,
    filled: true,
    fillColor: fillColor ?? AppColors.fieldColor,
    isDense: isDense,
    contentPadding: contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isDense ? 12 : 16,
        ),
    border: outlineInputBorder(borderColor ?? AppColors.borderColor, width: 1.0),
    enabledBorder:
        outlineInputBorder(borderColor ?? AppColors.borderColor, width: 1.0),
    focusedBorder: outlineInputBorder(AppColors.borderFocused, width: 1.8),
    errorBorder: outlineInputBorder(AppColors.error, width: 1.0),
    focusedErrorBorder: outlineInputBorder(AppColors.error, width: 1.8),
    errorStyle: const TextStyle(
      color: AppColors.error,
      fontSize: 11.5,
      height: 1.3,
      fontWeight: FontWeight.w500,
    ),
  );
}
