import 'package:flutter/material.dart';

import 'widgets/plot_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/task_card.dart';

/// Экран «Главная».
///
/// Сейчас все данные хардкод. Когда подключим backend (Приоритет 2):
/// 1. Превратим экран в StatefulWidget.
/// 2. В initState вызовем ApiService.getTasks() и getJournal().
/// 3. Заменим хардкод на map по полученным спискам.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Дача'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка участка
            const PlotCard(),
            const SizedBox(height: 16),

            // Задачи на сегодня
            const Text(
              'Задачи на сегодня',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TaskCard(
              title: 'Полить помидоры',
              zone: 'Теплица',
              isDone: false,
            ),
            const TaskCard(
              title: 'Прополоть грядку с морковью',
              zone: 'Огород',
              isDone: true,
            ),
            const TaskCard(
              title: 'Подкормить огурцы',
              zone: 'Теплица',
              isDone: false,
            ),
            const SizedBox(height: 16),

            // Статистика
            const Text(
              'Сезон 2026',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle,
                    label: 'Выполнено задач',
                    value: '24',
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.agriculture,
                    label: 'Культур посеяно',
                    value: '12',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.scale,
                    label: 'Урожай, кг',
                    value: '8.5',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book,
                    label: 'Записей',
                    value: '7',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
