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
import 'services/plants_service.dart'; // ← добавили
import 'services/zones_service.dart';

void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  final authService   = AuthService(apiClient, tokenStorage);
  final plotsService  = PlotsService(apiClient);
  final zonesService  = ZonesService(apiClient);
  final plantsService = PlantsService(apiClient); // ← добавили

  runApp(DachaApp(
    authService:   authService,
    plotsService:  plotsService,
    zonesService:  zonesService,
    plantsService: plantsService, // ← добавили
  ));
}

class DachaApp extends StatelessWidget {
  final AuthService   authService;
  final PlotsService  plotsService;
  final ZonesService  zonesService;
  final PlantsService plantsService; // ← добавили

  const DachaApp({
    super.key,
    required this.authService,
    required this.plotsService,
    required this.zonesService,
    required this.plantsService, // ← добавили
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ZonesService>.value(value: zonesService),
        Provider<PlantsService>.value(value: plantsService), // ← добавили
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