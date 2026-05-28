import 'package:flutter/material.dart';

import '../../core/zones/zones_provider.dart';

/// Экран создания новой зоны на участке.
///
/// ZonesProvider передаётся явно через конструктор, потому что экран
/// открывается в новом маршруте (Navigator.push) и не видит провайдера
/// из родительского маршрута.
class CreateZoneScreen extends StatefulWidget {
  final ZonesProvider zonesProvider;

  const CreateZoneScreen({super.key, required this.zonesProvider});

  @override
  State<CreateZoneScreen> createState() => _CreateZoneScreenState();
}

class _CreateZoneScreenState extends State<CreateZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _zoneType = 'garden';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await widget.zonesProvider.createZone(
      name: _nameController.text.trim(),
      zoneType: _zoneType,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      final msg = widget.zonesProvider.errorMessage ??
          'Не удалось создать зону. Попробуй позже.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая зона'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название зоны',
                  hintText: 'Например, Теплица, Картошка, Цветник',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название зоны';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _zoneType,
                decoration: const InputDecoration(labelText: 'Тип зоны'),
                items: const [
                  DropdownMenuItem(value: 'garden', child: Text('Огород')),
                  DropdownMenuItem(value: 'greenhouse', child: Text('Теплица')),
                  DropdownMenuItem(value: 'flowerbed', child: Text('Клумба / цветник')),
                  DropdownMenuItem(value: 'lawn', child: Text('Газон')),
                  DropdownMenuItem(value: 'orchard', child: Text('Сад / деревья')),
                  DropdownMenuItem(value: 'other', child: Text('Другое')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _zoneType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  hintText: 'Например, «томаты, 3 грядки»',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}