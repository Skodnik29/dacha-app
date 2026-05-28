import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import 'widgets/menu_item.dart';
import 'widgets/menu_section.dart';

/// Экран «Ещё»: профиль пользователя и пункты меню по разделам.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Меню'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Профиль (имя и email берём из AuthProvider — теперь это
          // настоящий залогиненный юзер, а не хардкод).
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: const Icon(Icons.person),
            ),
            title: Text(user?.name ?? 'Пользователь'),
            subtitle: Text(user?.email ?? ''),
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
          const Divider(),

          // Выход. AuthGate сам перебросит на LoginScreen.
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Выйти из аккаунта?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<AuthProvider>().logout();
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
