import 'package:flutter/material.dart';

/// Темы и стили приложения.
///
/// Сейчас тут только светлая тема. Когда понадобится тёмная — добавим
/// `static final ThemeData dark = ...` рядом с `light`.
class AppTheme {
  AppTheme._(); // приватный конструктор: класс используется только статически

  /// Основной зелёный цвет бренда — из него Material 3 сам генерирует
  /// всю палитру (primary, secondary, surface и т.д.).
  static const Color seedColor = Color(0xFF4CAF50);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}
