import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/plant.dart';
import '../../models/zone.dart';
import '../../core/plants/plants_provider.dart';
import '../../services/plants_service.dart';

class ZoneDetailScreen extends StatefulWidget {
  final Zone zone;

  const ZoneDetailScreen({super.key, required this.zone});

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  late final ZonePlantsProvider _plantsProvider;

  @override
  void initState() {
    super.initState();
    // ✅ Точно так же как ZonesProvider в plot_detail_screen.dart
    final service = context.read<PlantsService>();
    _plantsProvider = ZonePlantsProvider(service, zoneId: widget.zone.id);
    _plantsProvider.loadPlants();
  }

  @override
  void dispose() {
    _plantsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ZonePlantsProvider>.value(
      value: _plantsProvider,
      child: _ZoneDetailContent(zone: widget.zone),
    );
  }
}

class _ZoneDetailContent extends StatelessWidget {
  final Zone zone;

  const _ZoneDetailContent({required this.zone});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<ZonePlantsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(zone.name),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCatalog(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить растение'),
      ),
      body: Column(
        children: [
          _ZoneHeader(zone: zone),
          const Divider(height: 0),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ZonePlantsProvider provider) {
    if (provider.status == PlantsStatus.initial ||
        (provider.isLoading && provider.plants.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == PlantsStatus.error && provider.plants.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage ?? 'Не удалось загрузить растения.',
        onRetry: provider.loadPlants,
      );
    }

    if (provider.isEmpty) {
      return _EmptyPlantsView(onAdd: () => _openCatalog(context));
    }

    return RefreshIndicator(
      onRefresh: provider.loadPlants,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: provider.plants.length,
        itemBuilder: (_, i) {
          final plant = provider.plants[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlantInstanceCard(
              instance: plant,
              onStatusChange: (newStatus) async {
                await context.read<ZonePlantsProvider>().updatePlantStatus(
                    instanceId: plant.id, newStatus: newStatus);
              },
              onDelete: () async {
                final confirmed = await _confirmDelete(context, plant);
                if (confirmed && context.mounted) {
                  await context.read<ZonePlantsProvider>().removePlant(plant.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _openCatalog(BuildContext context) {
    // ✅ PlantsService берём из Provider — он уже зарегистрирован в main.dart
    final plantsService = context.read<PlantsService>();
    final plantsProvider = context.read<ZonePlantsProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PlantCatalogProvider(plantsService)..loadCatalog(),
          child: _PlantCatalogPicker(
            zoneId: zone.id,
            zonePlantsProvider: plantsProvider,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, PlantInstance plant) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить растение?'),
        content: Text('«${plant.displayName}» будет удалено из зоны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ── Шапка зоны ────────────────────────────────────────────────────────────

class _ZoneHeader extends StatelessWidget {
  final Zone zone;
  const _ZoneHeader({required this.zone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _humanType(zone.zoneType),
            style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600),
          ),
          if (zone.description != null && zone.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(zone.description!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[700])),
          ],
        ],
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
}

// ── Карточка растения ─────────────────────────────────────────────────────

const _statusColors = {
  'planned':   Color(0xFF2196F3),
  'active':    Color(0xFF4CAF50),
  'harvested': Color(0xFFFF9800),
  'removed':   Color(0xFF9E9E9E),
};

const _typeIcons = {
  'vegetable': '🥕',
  'tree':      '🌳',
  'berry':     '🍓',
  'flower':    '🌸',
  'shrub':     '🌿',
  'herb':      '🌱',
};

class _PlantInstanceCard extends StatelessWidget {
  final PlantInstance instance;
  final Future<void> Function(String status) onStatusChange;
  final VoidCallback onDelete;

  const _PlantInstanceCard({
    required this.instance,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[instance.status] ?? Colors.grey;
    final typeIcon = _typeIcons[instance.plantType] ?? '🌱';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(typeIcon,
                        style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(instance.displayName,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (instance.varietyName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        instance.varietyName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          instance.statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (instance.quantity != null) ...[
                        const SizedBox(width: 8),
                        Text('${instance.quantity} шт.',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ]),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: colorScheme.error,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PlantDetailSheet(
          instance: instance, onStatusChange: onStatusChange),
    );
  }
}

// ── Bottom sheet деталей растения ────────────────────────────────────────

class _PlantDetailSheet extends StatelessWidget {
  final PlantInstance instance;
  final Future<void> Function(String) onStatusChange;

  const _PlantDetailSheet(
      {required this.instance, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(instance.displayName,
              style: Theme.of(context).textTheme.titleLarge),
          if (instance.varietyName != null)
            Text(instance.varietyName!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 12),
          const Divider(),
          if (instance.plantedDate != null)
            _InfoRow(
              label: 'Посажено',
              value: '${instance.plantedDate!.day.toString().padLeft(2,'0')}'
                  '.${instance.plantedDate!.month.toString().padLeft(2,'0')}'
                  '.${instance.plantedDate!.year}',
            ),
          if (instance.quantity != null)
            _InfoRow(label: 'Количество', value: '${instance.quantity} шт.'),
          if (instance.areaSqm != null)
            _InfoRow(label: 'Площадь', value: '${instance.areaSqm} м²'),
          if (instance.notes != null) ...[
            const SizedBox(height: 8),
            Text('Заметки:', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(instance.notes!),
          ],
          const SizedBox(height: 20),
          Text('Изменить статус:', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['planned', 'active', 'harvested', 'removed']
                .map((s) => ChoiceChip(
                      label: Text(_statusLabel(s)),
                      selected: instance.status == s,
                      onSelected: (_) async {
                        await onStatusChange(s);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _statusLabel(String s) {
    const m = {
      'planned':   'Запланировано',
      'active':    'Растёт',
      'harvested': 'Собран урожай',
      'removed':   'Удалено',
    };
    return m[s] ?? s;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Каталог для выбора растения ───────────────────────────────────────────

const _plantTypes = [
  (value: null,        label: 'Все'),
  (value: 'vegetable', label: 'Овощи'),
  (value: 'tree',      label: 'Деревья'),
  (value: 'berry',     label: 'Ягоды'),
  (value: 'flower',    label: 'Цветы'),
  (value: 'shrub',     label: 'Кустарники'),
  (value: 'herb',      label: 'Травы'),
];

class _PlantCatalogPicker extends StatelessWidget {
  final String zoneId;
  final ZonePlantsProvider zonePlantsProvider;

  const _PlantCatalogPicker({
    required this.zoneId,
    required this.zonePlantsProvider,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlantCatalogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Выберите культуру')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _plantTypes.map((t) {
                final selected = provider.selectedType == t.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(t.label),
                    selected: selected,
                    onSelected: (_) => provider.setFilter(t.value),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildList(context, provider)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, PlantCatalogProvider provider) {
    if (provider.status == CatalogStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == CatalogStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage ?? 'Ошибка'),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: provider.loadCatalog,
                child: const Text('Повторить')),
          ],
        ),
      );
    }
    final plants = provider.filteredCatalog;
    if (plants.isEmpty) {
      return const Center(
          child: Text('Культуры не найдены',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: plants.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final plant = plants[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              plant.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
          title: Text(plant.name),
          subtitle: plant.nameLatin != null
              ? Text(plant.nameLatin!,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 12))
              : null,
          trailing: plant.varieties.isNotEmpty
              ? Text('${plant.varieties.length} сортов',
                  style: const TextStyle(fontSize: 11, color: Colors.grey))
              : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _AddPlantForm(
                plant: plant,
                onSave: (data) async {
                  final ok = await zonePlantsProvider.addPlant(
                    plantId: plant.id,
                    varietyId:   data['variety_id']   as String?,
                    customName:  data['custom_name']  as String?,
                    plantedDate: data['planted_date'] as DateTime?,
                    quantity:    data['quantity']     as int?,
                    areaSqm:     data['area_sqm']     as double?,
                    notes:       data['notes']        as String?,
                    status:      data['status']       as String? ?? 'active',
                  );
                  if (ok && context.mounted) {
                    Navigator.of(context).pop(); // форма
                    Navigator.of(context).pop(); // каталог
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Растение добавлено!'),
                          backgroundColor: Colors.green),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Форма добавления растения ─────────────────────────────────────────────

class _AddPlantForm extends StatefulWidget {
  final PlantCatalog plant;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _AddPlantForm({required this.plant, required this.onSave});

  @override
  State<_AddPlantForm> createState() => _AddPlantFormState();
}

class _AddPlantFormState extends State<_AddPlantForm> {
  final _formKey       = GlobalKey<FormState>();
  PlantVariety? _selectedVariety;
  final _customNameCtrl = TextEditingController();
  final _quantityCtrl   = TextEditingController();
  final _areaCtrl       = TextEditingController();
  final _notesCtrl      = TextEditingController();
  DateTime? _plantedDate;
  String _status = 'active';
  bool _loading  = false;

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _quantityCtrl.dispose();
    _areaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Посадить: ${widget.plant.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.plant.varieties.isNotEmpty) ...[
              DropdownButtonFormField<PlantVariety?>(
                decoration: const InputDecoration(
                    labelText: 'Сорт', border: OutlineInputBorder()),
                value: _selectedVariety,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Без сорта')),
                  ...widget.plant.varieties.map((v) =>
                      DropdownMenuItem(value: v, child: Text(v.name))),
                ],
                onChanged: (v) => setState(() => _selectedVariety = v),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _customNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Своё название (необязательно)',
                hintText: 'Например: «Томат у теплицы»',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_plantedDate == null
                  ? 'Дата посадки'
                  : 'Посажено: ${_fmt(_plantedDate!)}'),
              onTap: _pickDate,
              trailing: _plantedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _plantedDate = null))
                  : null,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Кол-во, шт.',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _areaCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Площадь, м²',
                      border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Статус', border: OutlineInputBorder()),
              value: _status,
              items: const [
                DropdownMenuItem(
                    value: 'planned', child: Text('Запланировано')),
                DropdownMenuItem(value: 'active', child: Text('Растёт')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Заметки', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _plantedDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await widget.onSave({
      'variety_id':  _selectedVariety?.id,
      'custom_name': _customNameCtrl.text.trim().isEmpty
          ? null : _customNameCtrl.text.trim(),
      'planted_date': _plantedDate,
      'quantity':  int.tryParse(_quantityCtrl.text),
      'area_sqm':  double.tryParse(_areaCtrl.text),
      'notes':     _notesCtrl.text.trim().isEmpty
          ? null : _notesCtrl.text.trim(),
      'status':    _status,
    });
    if (mounted) setState(() => _loading = false);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}'
      '.${d.month.toString().padLeft(2, '0')}'
      '.${d.year}';
}

// ── Пустое состояние ──────────────────────────────────────────────────────

class _EmptyPlantsView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPlantsView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'В зоне пока нет растений',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Нажмите кнопку ниже, чтобы выбрать культуру из справочника.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить растение'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}