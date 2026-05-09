class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? nationality;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.nationality,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    // Backend uses _id (MongoDB), fallback to id
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    // Backend uses fullName, fallback to name
    name: (json['fullName'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    // Backend may use avatar, avatarUrl, or avatar_url
    avatarUrl: (json['avatarUrl'] ?? json['avatar'] ?? json['avatar_url'])?.toString(),
    phone: json['phone']?.toString(),
    nationality: json['nationality']?.toString(),
    // Backend uses createdAt (camelCase), fallback to created_at
    createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
  );

  String get initials {
    if (name.isEmpty) return '';
    final names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
    'phone': phone,
    'nationality': nationality,
    'created_at': createdAt,
  };
}
