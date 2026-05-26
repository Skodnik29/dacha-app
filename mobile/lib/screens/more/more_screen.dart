import 'package:flutter/material.dart';

import 'widgets/menu_item.dart';
import 'widgets/menu_section.dart';

/// Экран «Ещё»: профиль пользователя и пункты меню по разделам.
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
          const MenuSection(title: 'Участок'),
          MenuItem(icon: Icons.map_outlined, title: 'Карта участка', onTap: () {}),
          MenuItem(icon: Icons.grass, title: 'Зоны и грядки', onTap: () {}),
          MenuItem(icon: Icons.eco, title: 'Посадки', onTap: () {}),
          MenuItem(icon: Icons.calendar_month, title: 'Посевной календарь', onTap: () {}),

          const MenuSection(title: 'Учёт'),
          MenuItem(icon: Icons.scale_outlined, title: 'Урожай', onTap: () {}),
          MenuItem(icon: Icons.inventory_2_outlined, title: 'Запасы', onTap: () {}),
          MenuItem(icon: Icons.receipt_long, title: 'Расходы', onTap: () {}),

          const MenuSection(title: 'Настройки'),
          MenuItem(icon: Icons.people_outline, title: 'Пользователи', onTap: () {}),
          MenuItem(icon: Icons.notifications_outlined, title: 'Уведомления', onTap: () {}),
          MenuItem(icon: Icons.telegram, title: 'Telegram-бот', onTap: () {}),
          MenuItem(icon: Icons.settings_outlined, title: 'Настройки', onTap: () {}),
          MenuItem(icon: Icons.help_outline, title: 'О приложении', onTap: () {}),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
