import 'package:flutter/material.dart';

import 'app/main_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DachaApp());
}

/// Корневой виджет приложения.
///
/// Здесь только настройка MaterialApp: тема, локализация (когда добавим),
/// начальный экран. Никакой бизнес-логики тут быть не должно.
class DachaApp extends StatelessWidget {
  const DachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дача',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainScreen(),
    );
  }
}
