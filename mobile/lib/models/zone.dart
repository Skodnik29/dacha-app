/// Зона на участке (грядка, теплица, цветник и т.п.).
///
/// Зеркалит схему `ZoneResponse` из backend (см. backend/app/schemas/plot.py).
class Zone {
  final String id;
  final String plotId;
  final String name;
  final String zoneType;
  final String? color;
  final String? icon;
  final String? description;
  final DateTime createdAt;

  const Zone({
    required this.id,
    required this.plotId,
    required this.name,
    required this.zoneType,
    this.color,
    this.icon,
    this.description,
    required this.createdAt,
  });

  /// Парсит ответ от /api/v1/plots/{plotId}/zones.
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      plotId: json['plot_id'] as String,
      name: json['name'] as String,
      zoneType: json['zone_type'] as String? ?? 'garden',
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}