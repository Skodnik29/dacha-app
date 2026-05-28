import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/plots/plots_provider.dart';

/// Форма создания нового участка.
///
/// Открывается из PlotsScreen через Navigator.push. После успешного
/// создания закрывает сама себя; список обновляется автоматически
/// (PlotsProvider добавляет новый участок в начало).
class CreatePlotScreen extends StatefulWidget {
  const CreatePlotScreen({super.key});

  @override
  State<CreatePlotScreen> createState() => _CreatePlotScreenState();
}

class _CreatePlotScreenState extends State<CreatePlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// true пока идёт POST-запрос — блокируем кнопку и форму.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<PlotsProvider>();
    final success = await provider.createPlot(
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      areaSqm: _parseArea(_areaController.text),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Участок создан')),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  /// Поле площади принимает либо м² («600»), либо сотки («6 соток», «6.5»).
  /// Если ввели число до 50 — считаем сотками и переводим в м².
  /// Иначе считаем сразу метрами квадратными.
  double? _parseArea(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final cleaned =
        trimmed.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(cleaned);
    if (value == null || value <= 0) return null;
    return value < 50 ? value * 100 : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый участок')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'Название *',
                    hintText: 'Например, «Дача в Цигломени»',
                    prefixIcon: Icon(Icons.yard_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название';
                    }
                    if (value.trim().length < 2) {
                      return 'Минимум 2 символа';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'Адрес',
                    hintText: 'Город, улица, номер',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'Площадь',
                    hintText: 'Сотки (если меньше 50) или м²',
                    prefixIcon: Icon(Icons.square_foot_outlined),
                    border: OutlineInputBorder(),
                    helperText: 'Например, «6» — 6 соток, «600» — 600 м²',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isSubmitting,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    hintText: 'Что есть на участке, особенности',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Создать', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
