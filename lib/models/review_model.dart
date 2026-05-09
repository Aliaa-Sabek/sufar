class Review {
  final int id;
  final String userId;
  final int targetId;
  final String targetType; // 'hotel' or 'destination'
  final double rating;
  final String comment;
  final String createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: _toInt(json['id']),
    userId: (json['user_id'] ?? '').toString(),
    targetId: _toInt(json['target_id']),
    targetType: (json['target_type'] ?? '').toString(),
    rating: _toDouble(json['rating']),
    comment: (json['comment'] ?? '').toString(),
    createdAt: (json['created_at'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'target_id': targetId,
    'target_type': targetType,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt,
  };
}
