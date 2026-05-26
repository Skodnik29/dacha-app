/// Пользователь приложения.
///
/// Поля совпадают с моделью users в backend (см. app/models/user.py),
/// но возвращаемая API структура — без password_hash.
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? region;
  final String? telegramId;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.region,
    this.telegramId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      region: json['region'] as String?,
      telegramId: json['telegram_id']?.toString(),
    );
  }
}
