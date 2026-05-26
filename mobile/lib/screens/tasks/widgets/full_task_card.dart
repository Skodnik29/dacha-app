import 'package:flutter/material.dart';

import '../../../models/task.dart';

/// Полная карточка задачи для списка на экране «Задачи».
/// Отличается от TaskCard на главной — здесь индикатор статуса вместо чекбокса.
class FullTaskCard extends StatelessWidget {
  final String title;
  final String zone;
  final String date;
  final TaskStatus status;

  const FullTaskCard({
    super.key,
    required this.title,
    required this.zone,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(Icons.yard_outlined, color: statusColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('$zone · $date'),
        trailing: Icon(Icons.circle, color: statusColor, size: 12),
      ),
    );
  }
}
