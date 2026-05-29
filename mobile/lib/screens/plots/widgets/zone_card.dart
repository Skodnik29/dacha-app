import 'package:flutter/material.dart';
import '../../../models/zone.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback? onTap; // ← добавили

  const ZoneCard({super.key, required this.zone, this.onTap}); // ← добавили

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
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap, // ← добавили
      ),
    );
  }

  Widget _buildSubtitle() {
    final parts = <String>[];
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
      case 'garden':     return 'Огород';
      case 'greenhouse': return 'Теплица';
      case 'flowerbed':  return 'Клумба';
      case 'lawn':       return 'Газон';
      case 'orchard':    return 'Сад';
      default:           return 'Зона';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'greenhouse': return Icons.home_work_outlined;
      case 'flowerbed':  return Icons.local_florist_outlined;
      case 'lawn':       return Icons.grass;
      case 'orchard':    return Icons.park_outlined;
      default:           return Icons.grid_on;
    }
  }

  Color _colorForType(ColorScheme cs, String type) {
    switch (type) {
      case 'greenhouse': return cs.tertiaryContainer;
      case 'flowerbed':  return cs.errorContainer;
      case 'lawn':       return cs.secondaryContainer;
      default:           return cs.primaryContainer;
    }
  }
}