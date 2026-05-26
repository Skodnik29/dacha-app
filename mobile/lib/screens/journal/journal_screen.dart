import 'package:flutter/material.dart';

import 'widgets/journal_card.dart';

/// Экран «Журнал»: лента записей наблюдений.
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          JournalCard(
            date: '24 мая 2026',
            text: 'Высадил рассаду томатов в теплицу. '
                'Всего 12 кустов сорта "Черри". '
                'Почва хорошо прогрелась.',
            zone: 'Теплица',
            hasPhoto: true,
          ),
          JournalCard(
            date: '22 мая 2026',
            text: 'Замечены следы тли на яблоне. '
                'Нужно обработать раствором хозяйственного мыла.',
            zone: 'Сад',
            hasPhoto: false,
          ),
          JournalCard(
            date: '20 мая 2026',
            text: 'Посеял морковь (сорт Нантская) и свёклу. '
                'Пролил тёплой водой.',
            zone: 'Огород',
            hasPhoto: true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Новая запись'),
      ),
    );
  }
}
