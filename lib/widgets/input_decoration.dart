import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

InputDecoration inputDecoration({
  String? hint,
  String? labelText,
  String? helperText,
  Widget? suffixIcon,
  Widget? prefixIcon,
  bool isDense = false,
  Color? prefixIconColor,
}) {
  OutlineInputBorder outlineInputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: AppColors.greyText.withValues(alpha: 0.55),
      fontSize: 14,
    ),
    labelText: labelText,
    labelStyle: TextStyle(
      color: AppColors.greyText.withValues(alpha: 0.7),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    helperText: helperText,
    helperMaxLines: 2,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixIconColor: prefixIconColor ?? AppColors.primary,
    filled: true,
    fillColor: AppColors.fieldColor,
    isDense: isDense,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: isDense ? 12 : 17,
    ),
    border: outlineInputBorder(AppColors.borderColor),
    enabledBorder: outlineInputBorder(AppColors.borderColor),
    focusedBorder: outlineInputBorder(AppColors.primary, width: 1.5),
    errorBorder: outlineInputBorder(Colors.redAccent),
    focusedErrorBorder: outlineInputBorder(Colors.redAccent, width: 1.5),
    errorStyle: const TextStyle(
      fontSize: 11.5,
      height: 1.3,
    ),
  );
}
