class PasswordModel {
  final int? id;
  final int userId;
  final String title;
  final String username;
  final String encryptedPassword;
  final String? url;
  final DateTime createdAt;

  PasswordModel({
    this.id,
    required this.userId,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    this.url,
    required this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'username': username,
      'password': encryptedPassword,
      'url': url,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      username: map['username'],
      encryptedPassword: map['password'],
      url: map['url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
