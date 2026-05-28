import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/plots/plots_provider.dart';
import 'create_plot_screen.dart';
import 'widgets/plot_card.dart';

/// Экран со списком участков текущего пользователя.
///
/// Открывается через Navigator.push с таба «Ещё» → «Мои участки».
/// При первом открытии автоматически подгружает список через API.
class PlotsScreen extends StatefulWidget {
  const PlotsScreen({super.key});

  @override
  State<PlotsScreen> createState() => _PlotsScreenState();
}

class _PlotsScreenState extends State<PlotsScreen> {
  @override
  void initState() {
    super.initState();
    // Запускаем загрузку после первого фрейма, чтобы Provider успел собраться.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlotsProvider>();
      if (provider.status == PlotsStatus.initial) {
        provider.loadPlots();
      }
    });
  }

  Future<void> _openCreateScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePlotScreen()),
    );
    // Возврат — список уже актуален (PlotsProvider добавил созданный участок
    // в начало в момент успешного POST).
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<PlotsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои участки'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateScreen,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildBody(PlotsProvider provider) {
    // Первая загрузка — крутилка на весь экран.
    if (provider.status == PlotsStatus.initial ||
        (provider.isLoading && provider.plots.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ошибка при пустом списке — большой экран с кнопкой «Повторить».
    if (provider.status == PlotsStatus.error && provider.plots.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage ?? 'Не удалось загрузить участки.',
        onRetry: () => provider.loadPlots(),
      );
    }

    // Пустой список — onboarding-плашка.
    if (provider.isEmpty) {
      return _EmptyView(onCreate: _openCreateScreen);
    }

    // Обычный список с pull-to-refresh.
    return RefreshIndicator(
      onRefresh: () => provider.loadPlots(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: provider.plots.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlotCard(plot: provider.plots[i]),
        ),
      ),
    );
  }
}

/// Заглушка для пустого списка.
class _EmptyView extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.yard_outlined, size: 96, color: colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'У вас пока нет участков',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте свой первый участок, чтобы вести задачи, журнал и учёт.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Создать участок'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Заглушка для состояния ошибки.
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
