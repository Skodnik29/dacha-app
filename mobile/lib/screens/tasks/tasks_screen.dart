import 'package:flutter/material.dart';

import '../../models/task.dart';
import 'widgets/full_task_card.dart';
import 'widgets/section_header.dart';

/// Экран «Задачи»: группированный список с разделами по дате/статусу.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(title: 'Просрочено', color: Colors.red),
          FullTaskCard(
            title: 'Обработать от тли',
            zone: 'Сад',
            date: '22 мая',
            status: TaskStatus.overdue,
          ),
          SectionHeader(title: 'Сегодня', color: Colors.orange),
          FullTaskCard(
            title: 'Полить помидоры',
            zone: 'Теплица',
            date: 'Сегодня',
            status: TaskStatus.pending,
          ),
          FullTaskCard(
            title: 'Подкормить огурцы',
            zone: 'Теплица',
            date: 'Сегодня',
            status: TaskStatus.pending,
          ),
          SectionHeader(title: 'Завтра', color: Colors.blue),
          FullTaskCard(
            title: 'Прополоть морковь',
            zone: 'Огород',
            date: '26 мая',
            status: TaskStatus.planned,
          ),
          FullTaskCard(
            title: 'Посеять редис',
            zone: 'Огород',
            date: '26 мая',
            status: TaskStatus.planned,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Новая задача'),
      ),
    );
  }
}
