import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import 'main_screen.dart';

/// «Шлюз» авторизации.
///
/// Это новая точка входа приложения (вместо прямого MainScreen в main.dart).
/// Логика:
///   1. При старте — initial → пробуем автологин через сохранённый токен.
///   2. loading → крутилка.
///   3. authenticated → MainScreen.
///   4. unauthenticated → LoginScreen.
///
/// Когда AuthProvider меняет статус (login/logout), context.watch
/// перерисовывает этот виджет автоматически.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Запускаем автологин после первого фрейма, чтобы Provider успел собраться.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    switch (status) {
      case AuthStatus.authenticated:
        return const MainScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
