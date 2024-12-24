import 'dart:convert';
import 'package:flutter/material.dart';

class CustomTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final double borderRadius;
  final double elevation;
  
  const CustomTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
  });
  
  // 从JSON创建自定义主题
  factory CustomTheme.fromJson(Map<String, dynamic> json) {
    return CustomTheme(
      name: json['name'] as String,
      primaryColor: Color(json['primaryColor'] as int),
      secondaryColor: Color(json['secondaryColor'] as int),
      backgroundColor: Color(json['backgroundColor'] as int),
      surfaceColor: Color(json['surfaceColor'] as int),
      textColor: Color(json['textColor'] as int),
      borderRadius: json['borderRadius'] as double? ?? 8.0,
      elevation: json['elevation'] as double? ?? 2.0,
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'textColor': textColor.value,
      'borderRadius': borderRadius,
      'elevation': elevation,
    };
  }
  
  // 转换为ThemeData
  ThemeData toThemeData({bool isDark = false}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: _getContrastColor(primaryColor),
        onSecondary: _getContrastColor(secondaryColor),
        onBackground: textColor,
        onSurface: textColor,
        error: Colors.red,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: _getContrastColor(primaryColor),
        elevation: elevation,
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _getContrastColor(primaryColor),
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
  
  // 获取对比色
  Color _getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black
        : Colors.white;
  }
  
  // 预设主题列表
  static List<CustomTheme> presetThemes = [
    CustomTheme(
      name: '经典蓝',
      primaryColor: Colors.blue,
      secondaryColor: Colors.blueAccent,
      backgroundColor: Colors.white,
      surfaceColor: Colors.white,
      textColor: Colors.black87,
    ),
    CustomTheme(
      name: '活力橙',
      primaryColor: Colors.orange,
      secondaryColor: Colors.orangeAccent,
      backgroundColor: Colors.white,
      surfaceColor: Colors.white,
      textColor: Colors.black87,
    ),
    CustomTheme(
      name: '自然绿',
      primaryColor: Colors.green,
      secondaryColor: Colors.greenAccent,
      backgroundColor: Colors.white,
      surfaceColor: Colors.white,
      textColor: Colors.black87,
    ),
    CustomTheme(
      name: '优雅紫',
      primaryColor: Colors.purple,
      secondaryColor: Colors.purpleAccent,
      backgroundColor: Colors.white,
      surfaceColor: Colors.white,
      textColor: Colors.black87,
    ),
  ];
} 