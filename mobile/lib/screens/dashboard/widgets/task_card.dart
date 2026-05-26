import 'package:flutter/material.dart';

/// Карточка задачи с чекбоксом — используется на главном экране
/// в блоке «Задачи на сегодня».
///
/// Для полноценной карточки задачи (со статусом, датой) см.
/// `screens/tasks/widgets/full_task_card.dart`.
class TaskCard extends StatefulWidget {
  final String title;
  final String zone;
  final bool isDone;

  const TaskCard({
    super.key,
    required this.title,
    required this.zone,
    required this.isDone,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
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
