import 'package:flutter/material.dart';

import '../plot_detail_screen.dart';
import '../../../models/plot.dart';

/// Карточка одного участка в списке.
///
/// По тапу открывает экран деталей участка с зонами.
class PlotCard extends StatelessWidget {
  final Plot plot;

  const PlotCard({super.key, required this.plot});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.yard, color: colorScheme.primary),
        ),
        title: Text(
          plot.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: _buildSubtitle(),
        trailing: _RoleBadge(role: plot.role),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlotDetailScreen(plot: plot),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubtitle() {
    // Собираем строку «адрес · 6 соток» — пропускаем пустые куски.
    final parts = <String>[];
    if (plot.address != null && plot.address!.isNotEmpty) {
      parts.add(plot.address!);
    }
    if (plot.areaSqm != null && plot.areaSqm! > 0) {
      parts.add(_formatArea(plot.areaSqm!));
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        parts.join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 600.0 → «6 соток», 800.0 → «8 соток», 1500.0 → «1500 м²».
  /// Сотка = 100 м². Если ровные сотки — показываем в сотках, иначе в м².
  String _formatArea(double sqm) {
    if (sqm >= 100 && sqm % 100 == 0) {
      final sotki = (sqm / 100).round();
      return '$sotki ${_plural(sotki, 'сотка', 'сотки', 'соток')}';
    }
    final rounded =
        sqm.toStringAsFixed(sqm.truncateToDouble() == sqm ? 0 : 1);
    return '$rounded м²';
  }

  /// Простой плюрализатор: 1 сотка, 2-4 сотки, 5+ соток.
  String _plural(int n, String one, String few, String many) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }
}

/// Бейджик с ролью пользователя на участке.
class _RoleBadge extends StatelessWidget {
  final String? role;
  const _RoleBadge({this.role});

  @override
  Widget build(BuildContext context) {
    if (role == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (role) {
      case 'admin':
        bg = colorScheme.primary;
        fg = Colors.white;
        label = 'Админ';
        break;
      case 'member':
        bg = colorScheme.secondaryContainer;
        fg = colorScheme.onSecondaryContainer;
        label = 'Участник';
        break;
      case 'viewer':
        bg = Colors.grey.shade300;
        fg = Colors.black87;
        label = 'Просмотр';
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.black87;
        label = role!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}