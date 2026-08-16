import 'package:flutter/material.dart';
import 'package:travel_buddy_finder/utils/app_colors.dart';

InputDecoration inputDecoration({
  String? hint,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  OutlineInputBorder border(Color color, {double width = 1}) {
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
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,

    filled: true,
    fillColor: AppColors.fieldColor,

    hintStyle: TextStyle(
      color: AppColors.greyText.withValues(alpha: 0.65),
      fontSize: 14,
    ),

    prefixIconColor: AppColors.greyText,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),

    border: border(AppColors.borderColor),

    enabledBorder: border(
      AppColors.borderColor,
    ),

    focusedBorder: border(
      AppColors.primary,
      width: 1.5,
    ),

    errorBorder: border(
      Colors.redAccent,
    ),

    focusedErrorBorder: border(
      Colors.redAccent,
      width: 1.5,
    ),

    errorStyle: const TextStyle(
      fontSize: 11.5,
      height: 1.3,
    ),
  );
}