class User {
  final int? id;
  final String name;
  final String username;
  final String hashedPassword;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.hashedPassword,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "username": username,
      "password": hashedPassword,
      "created_at": createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"],
      name: map["name"],
      username: map["username"],
      hashedPassword: map["password"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }
}
