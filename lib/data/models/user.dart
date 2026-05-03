enum UserRole { customer, owner, publisher }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? publisherId;
  final int orders;
  final int points;
  final int favorites;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.publisherId,
    this.orders = 0,
    this.points = 0,
    this.favorites = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is List) return value.length; 
      return 0;
    }

    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['username'] ?? 'مستخدم').toString(),
      email: (json['email'] ?? '').toString(),
      role: _parseRole(json['role']),
      publisherId: json['publisherId']?.toString(),
      orders: asInt(json['orders']),
      points: asInt(json['points']),
      favorites: asInt(json['favorites'] ?? json['favorites_count']),
    );
  }

  static UserRole _parseRole(dynamic role) {
    final r = role?.toString().toLowerCase();
    if (r == 'owner' || r == 'admin') return UserRole.owner;
    if (r == 'publisher') return UserRole.publisher;
    return UserRole.customer;
  }
}
