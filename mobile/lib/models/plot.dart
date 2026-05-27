/// Участок (дача/сад/огород).
///
/// Зеркалит схему `PlotResponse` из backend (см. backend/app/schemas/plot.py).
/// Поля `latitude` / `longitude` в текущей версии API не возвращаются,
/// поэтому в модели их нет — добавим позже, когда подключим карту.
class Plot {
  final String id;
  final String name;
  final String? address;
  final double? areaSqm;
  final String? description;
  final bool isArchived;
  final DateTime createdAt;

  /// Роль текущего пользователя на этом участке: admin / member / viewer.
  /// Может быть null, если backend не вернул (на /plots возвращается всегда).
  final String? role;

  const Plot({
    required this.id,
    required this.name,
    this.address,
    this.areaSqm,
    this.description,
    required this.isArchived,
    required this.createdAt,
    this.role,
  });

  /// Парсит ответ от /api/v1/plots или /api/v1/plots/{id}.
  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      // area_sqm может прийти как int или double — приводим аккуратно.
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
      description: json['description'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String?,
    );
  }

  /// Удобно для UI: «У меня роль admin → могу редактировать».
  bool get isAdmin => role == 'admin';
}
