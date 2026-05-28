import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/auth_gate.dart';
import 'core/api/api_client.dart';
import 'core/api/token_storage.dart';
import 'core/auth/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';

void main() {
  // Собираем зависимости один раз при старте.
  // Порядок важен: TokenStorage → ApiClient → AuthService → AuthProvider.
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authService = AuthService(apiClient, tokenStorage);

  runApp(DachaApp(authService: authService));
}

class DachaApp extends StatelessWidget {
  final AuthService authService;

  const DachaApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // AuthProvider будет доступен через context.watch/read из любого
      // виджета ниже по дереву.
      create: (_) => AuthProvider(authService),
      child: MaterialApp(
        title: 'Дача',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
