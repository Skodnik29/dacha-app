import 'package:flutter/material.dart';

import '../../../models/zone.dart';

/// Карточка одной зоны на участке.
///
/// Показывает название, тип и описание (если есть).
class ZoneCard extends StatelessWidget {
  final Zone zone;

  const ZoneCard({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final iconData = _iconForType(zone.zoneType);
    final bgColor = _colorForType(colorScheme, zone.zoneType);

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(iconData, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          zone.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: _buildSubtitle(),
        // В будущем сюда можно добавить onTap → детали зоны.
      ),
    );
  }

  Widget _buildSubtitle() {
    final parts = <String>[];

    // Тип зоны — человекочитаемый.
    parts.add(_humanType(zone.zoneType));

    if (zone.description != null && zone.description!.isNotEmpty) {
      parts.add(zone.description!);
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

  String _humanType(String raw) {
    switch (raw) {
      case 'garden':
        return 'Огород';
      case 'greenhouse':
        return 'Теплица';
      case 'flowerbed':
        return 'Клумба';
      case 'lawn':
        return 'Газон';
      case 'orchard':
        return 'Сад';
      default:
        return 'Другая зона';
    }
  }

  IconData _iconForType(String raw) {
    switch (raw) {
      case 'garden':
        return Icons.grass;
      case 'greenhouse':
        return Icons.house_siding;
      case 'flowerbed':
        return Icons.local_florist;
      case 'lawn':
        return Icons.park;
      case 'orchard':
        return Icons.forest;
      default:
        return Icons.yard;
    }
  }

  Color _colorForType(ColorScheme scheme, String raw) {
    switch (raw) {
      case 'garden':
        return scheme.primaryContainer;
      case 'greenhouse':
        return scheme.tertiaryContainer;
      case 'flowerbed':
        return scheme.secondaryContainer;
      case 'lawn':
        return scheme.primaryContainer.withOpacity(0.8);
      case 'orchard':
        return scheme.tertiaryContainer.withOpacity(0.9);
      default:
        return scheme.surfaceVariant;
    }
  }
}