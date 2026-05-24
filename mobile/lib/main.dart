import 'package:flutter/material.dart';

void main() {
  runApp(const DachaApp());
}

class DachaApp extends StatelessWidget {
  const DachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дача',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ==================== ГЛАВНЫЙ ЭКРАН С НАВИГАЦИЕЙ ====================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TasksScreen(),
    JournalScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Задачи',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Журнал',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: 'Ещё',
          ),
        ],
      ),
    );
  }
}

// ==================== ЭКРАН: ГЛАВНАЯ ====================

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
            _PlotCard(),
            const SizedBox(height: 16),

            // Задачи на сегодня
            const Text(
              'Задачи на сегодня',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _TaskCard(
              title: 'Полить помидоры',
              zone: 'Теплица',
              isDone: false,
            ),
            _TaskCard(
              title: 'Прополоть грядку с морковью',
              zone: 'Огород',
              isDone: true,
            ),
            _TaskCard(
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
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Выполнено задач',
                    value: '24',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.agriculture,
                    label: 'Культур посеяно',
                    value: '12',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.scale,
                    label: 'Урожай, кг',
                    value: '8.5',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
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

class _PlotCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.yard, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мой участок',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '4 зоны · 12 культур',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final String title;
  final String zone;
  final bool isDone;

  const _TaskCard({
    required this.title,
    required this.zone,
    required this.isDone,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.isDone;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: _isDone,
          activeColor: Colors.green,
          onChanged: (val) => setState(() => _isDone = val ?? false),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            decoration: _isDone ? TextDecoration.lineThrough : null,
            color: _isDone ? Colors.grey : null,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.place, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(widget.zone, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.grey),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ЭКРАН: ЗАДАЧИ ====================

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
        children: [
          _SectionHeader(title: 'Просрочено', color: Colors.red),
          _FullTaskCard(
            title: 'Обработать от тли',
            zone: 'Сад',
            date: '22 мая',
            status: TaskStatus.overdue,
          ),
          _SectionHeader(title: 'Сегодня', color: Colors.orange),
          _FullTaskCard(
            title: 'Полить помидоры',
            zone: 'Теплица',
            date: 'Сегодня',
            status: TaskStatus.pending,
          ),
          _FullTaskCard(
            title: 'Подкормить огурцы',
            zone: 'Теплица',
            date: 'Сегодня',
            status: TaskStatus.pending,
          ),
          _SectionHeader(title: 'Завтра', color: Colors.blue),
          _FullTaskCard(
            title: 'Прополоть морковь',
            zone: 'Огород',
            date: '26 мая',
            status: TaskStatus.planned,
          ),
          _FullTaskCard(
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

enum TaskStatus { pending, overdue, planned, done }

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullTaskCard extends StatelessWidget {
  final String title;
  final String zone;
  final String date;
  final TaskStatus status;

  const _FullTaskCard({
    required this.title,
    required this.zone,
    required this.date,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case TaskStatus.overdue:
        return Colors.red;
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.planned:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor.withOpacity(0.15),
          child: Icon(Icons.yard_outlined, color: _statusColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('$zone · $date'),
        trailing: Icon(Icons.circle, color: _statusColor, size: 12),
      ),
    );
  }
}

// ==================== ЭКРАН: ЖУРНАЛ ====================

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
        children: [
          _JournalCard(
            date: '24 мая 2026',
            text: 'Высадил рассаду томатов в теплицу. '
                'Всего 12 кустов сорта "Черри". '
                'Почва хорошо прогрелась.',
            zone: 'Теплица',
            hasPhoto: true,
          ),
          _JournalCard(
            date: '22 мая 2026',
            text: 'Замечены следы тли на яблоне. '
                'Нужно обработать раствором хозяйственного мыла.',
            zone: 'Сад',
            hasPhoto: false,
          ),
          _JournalCard(
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

class _JournalCard extends StatelessWidget {
  final String date;
  final String text;
  final String zone;
  final bool hasPhoto;

  const _JournalCard({
    required this.date,
    required this.text,
    required this.zone,
    required this.hasPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    if (hasPhoto)
                      const Icon(Icons.photo, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        zone,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ==================== ЭКРАН: ЕЩЁ ====================

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Меню'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Профиль
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: const Icon(Icons.person),
            ),
            title: const Text('Денис'),
            subtitle: const Text('Мой участок · Администратор'),
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(),

          // Разделы
          _MenuSection(title: 'Участок'),
          _MenuItem(icon: Icons.map_outlined, title: 'Карта участка', onTap: () {}),
          _MenuItem(icon: Icons.grass, title: 'Зоны и грядки', onTap: () {}),
          _MenuItem(icon: Icons.eco, title: 'Посадки', onTap: () {}),
          _MenuItem(icon: Icons.calendar_month, title: 'Посевной календарь', onTap: () {}),

          _MenuSection(title: 'Учёт'),
          _MenuItem(icon: Icons.scale_outlined, title: 'Урожай', onTap: () {}),
          _MenuItem(icon: Icons.inventory_2_outlined, title: 'Запасы', onTap: () {}),
          _MenuItem(icon: Icons.receipt_long, title: 'Расходы', onTap: () {}),

          _MenuSection(title: 'Настройки'),
          _MenuItem(icon: Icons.people_outline, title: 'Пользователи', onTap: () {}),
          _MenuItem(icon: Icons.notifications_outlined, title: 'Уведомления', onTap: () {}),
          _MenuItem(icon: Icons.telegram, title: 'Telegram-бот', onTap: () {}),
          _MenuItem(icon: Icons.settings_outlined, title: 'Настройки', onTap: () {}),
          _MenuItem(icon: Icons.help_outline, title: 'О приложении', onTap: () {}),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  const _MenuSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}