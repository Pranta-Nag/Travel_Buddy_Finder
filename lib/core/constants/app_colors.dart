import 'package:flutter/material.dart';

/// Centralized color palette for Travel Buddy Finder.
/// Built with a modern, high-contrast, professional mobile app aesthetic:
/// - Brand Primary: Vibrant Royal Ocean Blue (#2563EB) & Deep Cobalt (#1D4ED8)
/// - Clean Neutrals: Slate tones (#0F172A, #334155, #64748B, #E2E8F0, #F8FAFC)
/// - Semantic Accents: Emerald for Success, Amber for Warnings/Ratings, Crimson for Errors
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8); // Deep Cobalt
  static const Color primaryLight = Color(0xFF3B82F6); // Soft Bright Blue
  static const Color primarySoft = Color(0xFFEFF6FF); // Ultra-light blue tint (50)

  // Secondary & Accents
  static const Color secondary = Color(0xFF0EA5E9); // Ocean Sky (500)
  static const Color accent = Color(0xFFF59E0B); // Amber / Gold for stars & ratings

  // Neutrals & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Clean Slate-50
  static const Color cardBackground = Colors.white; // Pure white cards
  static const Color fieldColor = Color(0xFFF8FAFC); // Subtle light field fill
  static const Color borderColor = Color(0xFFE2E8F0); // Elegant Slate-200 border
  static const Color borderFocused = Color(0xFF2563EB); // Focus ring
  static const Color divider = Color(0xFFE2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900 (High contrast)
  static const Color textSecondary = Color(0xFF475569); // Slate-600 (Secondary labels)
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400 (Placeholders)
  static const Color greyText = Color(0xFF64748B); // Slate-500 (Preserved for compatibility)

  // Status & Semantics
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorSoft = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color disabled = Color(0xFFCBD5E1); // Slate-300

  // Buttons & CTAs
  static const Color buttonColor = Color(0xFF2563EB); // Matches primary
}
