import 'package:flutter/material.dart';

/// Статус задачи. Совпадает по смыслу с серверным enum в backend
/// (`pending`, `done`, `skipped`), плюс UI-производные `overdue` и `planned`,
/// которые вычисляются по дате на клиенте.
enum TaskStatus {
  pending,
  overdue,
  planned,
  done;

  /// Цвет индикатора статуса в UI. Держим маппинг рядом с enum,
  /// чтобы не дублировать его в виджетах.
  Color get color {
    switch (this) {
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
}

/// Задача на участке.
///
/// Пока модель используется только для UI-заглушек. Когда подключим
/// backend (Приоритет 2), добавим `fromJson` / `toJson` и поля
/// id, plotId, zoneId и т.п.
class Task {
  final String title;
  final String zone;
  final String date;
  final TaskStatus status;
  final bool isDone;

  const Task({
    required this.title,
    required this.zone,
    this.date = '',
    this.status = TaskStatus.pending,
    this.isDone = false,
  });
}
