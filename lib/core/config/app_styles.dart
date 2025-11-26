import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App text styles and design system constants  
class AppStyles {
  // Typography
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.none,
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.none,
  );
  
  // Aliases for common usage
  static const TextStyle title = title2;
  static const TextStyle subtitle = subheadline;
  static const TextStyle button = headline;
  static const TextStyle cardTitle = title3;
  static const TextStyle cardSubtitle = footnote;
  
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 24.0;
  static const double cardRadius = radiusLarge;
  static const double sheetRadius = radiusXLarge;
  
  // Component sizes
  static const double buttonHeight = 50.0;
  static const double inputHeight = 44.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeLarge = 32.0;
  
  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 20,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );
  
  static const BoxShadow elevatedShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 30,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );
  
  static const BoxShadow subtleShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 10,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );
  
  // Button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      );

  static ButtonStyle get secondaryButtonStyle => primaryButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(AppColors.secondary),
        foregroundColor: WidgetStateProperty.all(AppColors.textPrimary),
      );

  static ButtonStyle get destructiveButtonStyle => primaryButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(AppColors.error),
      );

  // Input decoration
  static InputDecoration get inputDecoration => InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: body.copyWith(color: AppColors.textSecondary),
      );
  
  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // Animation curves
  static const Curve animationCurve = Curves.easeOutCubic;
  static const Curve animationCurveSpring = Curves.elasticOut;
}
