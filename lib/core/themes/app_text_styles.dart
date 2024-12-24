import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application text styles
class AppTextStyles {
  // Headings
  static TextStyle heading1({
    Color? color,
    FontWeight weight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: 32,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.2,
    );
  }

  static TextStyle heading2({
    Color? color,
    FontWeight weight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: 28,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.2,
    );
  }

  static TextStyle heading3({
    Color? color,
    FontWeight weight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: 24,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.3,
    );
  }

  // Body Text
  static TextStyle bodyLarge({
    Color? color,
    FontWeight weight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({
    Color? color,
    FontWeight weight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.5,
    );
  }

  static TextStyle bodySmall({
    Color? color,
    FontWeight weight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: weight,
      color: color ?? AppColors.textSecondaryLight,
      height: 1.5,
    );
  }

  // Button Text
  static TextStyle buttonLarge({
    Color? color,
    FontWeight weight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: weight,
      color: color ?? Colors.white,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  static TextStyle buttonMedium({
    Color? color,
    FontWeight weight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: weight,
      color: color ?? Colors.white,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  // Caption Text
  static TextStyle caption({
    Color? color,
    FontWeight weight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: weight,
      color: color ?? AppColors.textSecondaryLight,
      height: 1.4,
    );
  }

  // Label Text
  static TextStyle label({
    Color? color,
    FontWeight weight = FontWeight.medium,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.4,
      letterSpacing: 0.25,
    );
  }

  // Amount Text
  static TextStyle amount({
    Color? color,
    FontWeight weight = FontWeight.bold,
    double? fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 24,
      fontWeight: weight,
      color: color ?? AppColors.textPrimaryLight,
      height: 1.2,
      letterSpacing: 0.5,
    );
  }

  // Link Text
  static TextStyle link({
    Color? color,
    FontWeight weight = FontWeight.medium,
    bool underline = true,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: weight,
      color: color ?? AppColors.primaryLight,
      height: 1.5,
      decoration: underline ? TextDecoration.underline : null,
    );
  }
} 