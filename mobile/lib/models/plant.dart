class PlantCatalog {
  final String id;
  final String name;
  final String? nameLatin;
  final String plantType;
  final String? description;
  final bool isSystem;
  final List<PlantVariety> varieties;

  const PlantCatalog({
    required this.id,
    required this.name,
    this.nameLatin,
    required this.plantType,
    this.description,
    required this.isSystem,
    this.varieties = const [],
  });

  factory PlantCatalog.fromJson(Map<String, dynamic> json) => PlantCatalog(
        id: json['id'] as String,
        name: json['name'] as String,
        nameLatin: json['name_latin'] as String?,
        plantType: json['plant_type'] as String? ?? 'other',
        description: json['description'] as String?,
        isSystem: json['is_system'] as bool? ?? true,
        varieties: (json['varieties'] as List<dynamic>? ?? [])
            .map((e) => PlantVariety.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PlantVariety {
  final String id;
  final String plantId;
  final String name;
  final String? description;

  const PlantVariety({
    required this.id,
    required this.plantId,
    required this.name,
    this.description,
  });

  factory PlantVariety.fromJson(Map<String, dynamic> json) => PlantVariety(
        id: json['id'] as String,
        plantId: json['plant_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}

class PlantInstance {
  final String id;
  final String zoneId;
  final String plantId;
  final String plantName;
  final String plantType;
  final String? varietyId;
  final String? varietyName;
  final String? customName;
  final DateTime? plantedDate;
  final int? quantity;
  final double? areaSqm;
  final String? notes;
  final String status;
  final DateTime createdAt;

  const PlantInstance({
    required this.id,
    required this.zoneId,
    required this.plantId,
    required this.plantName,
    required this.plantType,
    this.varietyId,
    this.varietyName,
    this.customName,
    this.plantedDate,
    this.quantity,
    this.areaSqm,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  String get displayName =>
      customName ?? varietyName ?? plantName;

  String get statusLabel {
    const labels = {
      'planned':   'Запланировано',
      'active':    'Растёт',
      'harvested': 'Собран урожай',
      'removed':   'Удалено',
    };
    return labels[status] ?? status;
  }

  factory PlantInstance.fromJson(Map<String, dynamic> json) => PlantInstance(
        id:          json['id'] as String,
        zoneId:      json['zone_id'] as String,
        plantId:     json['plant_id'] as String,
        plantName:   json['plant_name'] as String,
        plantType:   json['plant_type'] as String? ?? 'other',
        varietyId:   json['variety_id'] as String?,
        varietyName: json['variety_name'] as String?,
        customName:  json['custom_name'] as String?,
        plantedDate: json['planted_date'] != null
            ? DateTime.parse(json['planted_date'] as String)
            : null,
        quantity:    json['quantity'] as int?,
        areaSqm:     (json['area_sqm'] as num?)?.toDouble(),
        notes:       json['notes'] as String?,
        status:      json['status'] as String? ?? 'active',
        createdAt:   DateTime.parse(json['created_at'] as String),
      );
}