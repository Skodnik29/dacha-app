import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/auth_gate.dart';
import 'core/api/api_client.dart';
import 'core/api/token_storage.dart';
import 'core/auth/auth_provider.dart';
import 'core/plots/plots_provider.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/plots_service.dart';
import 'services/zones_service.dart';

void main() {
  // Собираем зависимости один раз при старте приложения.
  // Порядок важен: TokenStorage → ApiClient → сервисы → провайдеры.
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  final authService = AuthService(apiClient, tokenStorage);
  final plotsService = PlotsService(apiClient);
  final zonesService = ZonesService(apiClient);

  runApp(DachaApp(
    authService: authService,
    plotsService: plotsService,
    zonesService: zonesService,
  ));
}

class DachaApp extends StatelessWidget {
  final AuthService authService;
  final PlotsService plotsService;
  final ZonesService zonesService;

  const DachaApp({
    super.key,
    required this.authService,
    required this.plotsService,
    required this.zonesService,
  });

  @override
  Widget build(BuildContext context) {
    // MultiProvider регистрирует сразу несколько зависимостей и состояний.
    return MultiProvider(
      providers: [
        // Сервис зон как обычный провайдер (без собственного состояния).
        Provider<ZonesService>.value(value: zonesService),

        // Состояния.
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => PlotsProvider(plotsService)),
      ],
      child: MaterialApp(
        title: 'Дача',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
