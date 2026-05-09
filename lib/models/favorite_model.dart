class Favorite {
  final String id;
  final String userId;
  final String targetId;
  final String targetType; // 'hotel' or 'destination'
  final String createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['user'] ?? json['userId'] ?? json['user_id'] ?? '').toString(),
    targetId: (json['targetId'] ?? json['target_id'] ?? '').toString(),
    targetType: (json['targetType'] ?? json['target_type'] ?? '').toString(),
    createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'targetId': targetId,
    'targetType': targetType,
  };
}
