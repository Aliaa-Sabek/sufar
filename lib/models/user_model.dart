class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? nationality;
  final String? gender;
  final String? dateOfBirth;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.nationality,
    this.gender,
    this.dateOfBirth,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    // Backend uses _id (MongoDB), fallback to id
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    // Backend uses fullName, fallback to name
    name: (json['fullName'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    // Backend may use avatar, avatarUrl, or avatar_url
    avatarUrl: (json['avatarUrl'] ??
            json['avatar'] ??
            json['avatar_url'] ??
            json['profilePicture'])
        ?.toString(),
    phone: json['phone']?.toString(),
    nationality: json['nationality']?.toString(),
    gender: json['gender']?.toString(),
    dateOfBirth: (json['dateOfBirth'] ?? json['date_of_birth'])?.toString(),
    // Backend uses createdAt (camelCase), fallback to created_at
    createdAt: (json['createdAt'] ??
            json['created_at'] ??
            json['memberSince'] ??
            '')
        .toString(),
  );

  String get initials {
    if (name.isEmpty) return '?';
    final names = name.split(' ').where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  /// Parses login, profile, or update responses without treating error bodies as users.
  static UserModel? fromApiResponse(Map<String, dynamic> json) {
    if (json['user'] is Map) {
      final user = UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map));
      if (user.name.isNotEmpty || user.email.isNotEmpty) return user;
    }

    if (json.containsKey('fullName') ||
        json.containsKey('email') ||
        json.containsKey('name')) {
      final user = UserModel.fromJson(json);
      if (user.name.isNotEmpty || user.email.isNotEmpty) return user;
    }

    return null;
  }

  UserModel mergeWith(UserModel other) => UserModel(
        id: other.id.isNotEmpty ? other.id : id,
        name: other.name.isNotEmpty ? other.name : name,
        email: other.email.isNotEmpty ? other.email : email,
        avatarUrl: other.avatarUrl ?? avatarUrl,
        phone: other.phone ?? phone,
        nationality: other.nationality ?? nationality,
        gender: other.gender ?? gender,
        dateOfBirth: other.dateOfBirth ?? dateOfBirth,
        createdAt: other.createdAt.isNotEmpty ? other.createdAt : createdAt,
      );

  Map<String, dynamic> toStorageJson() => {
        '_id': id,
        'id': id,
        'fullName': name,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'phone': phone,
        'nationality': nationality,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'createdAt': createdAt,
      };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
    'phone': phone,
    'nationality': nationality,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'created_at': createdAt,
  };
}
