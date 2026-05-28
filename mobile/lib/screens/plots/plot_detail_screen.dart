import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/zones/zones_provider.dart';
import '../../models/plot.dart';
import '../../models/zone.dart';
import '../../services/zones_service.dart';
import 'create_zone_screen.dart';
import 'widgets/zone_card.dart';

/// Экран деталей участка: краткая информация + список зон.
class PlotDetailScreen extends StatefulWidget {
  final Plot plot;

  const PlotDetailScreen({super.key, required this.plot});

  @override
  State<PlotDetailScreen> createState() => _PlotDetailScreenState();
}

class _PlotDetailScreenState extends State<PlotDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Первичная загрузка зон после первого фрейма.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ZonesProvider>();
      if (provider.status == ZonesStatus.initial) {
        provider.loadZones();
      }
    });
  }

  Future<void> _openCreateZone(ZonesProvider provider) async {
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      // Передаём уже существующий провайдер явно через конструктор
      builder: (_) => CreateZoneScreen(zonesProvider: provider),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // Получаем ZonesService из корневого Provider и создаём
    // локальный ZonesProvider, живущий только на этом экране.
    return Consumer<ZonesService>(
      builder: (context, service, _) {
        return ChangeNotifierProvider(
          create: (_) => ZonesProvider(
            service,
            plotId: widget.plot.id,
          ),
          child: _PlotDetailContent(plot: widget.plot, onAddZone: _openCreateZone),
        );
      },
    );
  }
}

class _PlotDetailContent extends StatelessWidget {
  final Plot plot;
  final void Function(ZonesProvider) onAddZone; // ← было VoidCallback

  const _PlotDetailContent({
    required this.plot,
    required this.onAddZone,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final zonesProvider = context.watch<ZonesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(plot.name),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => onAddZone(zonesProvider), // ← передаём провайдер
        icon: const Icon(Icons.add),
        label: const Text('Добавить зону'),
      ),
      body: Column(
        children: [
          _PlotHeader(plot: plot),
          const Divider(height: 0),
          Expanded(child: _buildZonesBody(zonesProvider)),
        ],
      ),
    );
  }

  Widget _buildZonesBody(ZonesProvider provider) {
    if (provider.status == ZonesStatus.initial ||
        (provider.isLoading && provider.zones.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == ZonesStatus.error && provider.zones.isEmpty) {
      return _ZonesErrorView(
        message: provider.errorMessage ?? 'Не удалось загрузить зоны.',
        onRetry: provider.loadZones,
      );
    }

    if (provider.isEmpty) {
  return _ZonesEmptyView(onCreate: () => onAddZone(provider));
    }

    return RefreshIndicator(
      onRefresh: provider.loadZones,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: provider.zones.length,
        itemBuilder: (_, i) {
          final zone = provider.zones[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ZoneCard(zone: zone),
          );
        },
      ),
    );
  }
}

/// Верхний блок с краткой информацией об участке.
class _PlotHeader extends StatelessWidget {
  final Plot plot;
  const _PlotHeader({required this.plot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];

    if (plot.address != null && plot.address!.isNotEmpty) {
      parts.add(plot.address!);
    }
    if (plot.areaSqm != null && plot.areaSqm! > 0) {
      parts.add(_formatArea(plot.areaSqm!));
    }

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plot.name,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (parts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              parts.join(' · '),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Участок создан: ${_formatDate(plot.createdAt)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatArea(double sqm) {
    if (sqm >= 100 && sqm % 100 == 0) {
      final sotki = (sqm / 100).round();
      return '$sotki соток';
    }
    final rounded =
        sqm.toStringAsFixed(sqm.truncateToDouble() == sqm ? 0 : 1);
    return '$rounded м²';
  }

  String _formatDate(DateTime dt) {
    // Пока простое форматирование ISO → yyyy-mm-dd.
    return dt.toLocal().toString().split(' ').first;
  }
}

/// Заглушка для пустого списка зон.
class _ZonesEmptyView extends StatelessWidget {
  final VoidCallback onCreate;
  const _ZonesEmptyView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grass, size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'На этом участке пока нет зон',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте первую зону: грядку, теплицу или клумбу.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Добавить зону'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Заглушка для ошибки загрузки зон.
class _ZonesErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ZonesErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}