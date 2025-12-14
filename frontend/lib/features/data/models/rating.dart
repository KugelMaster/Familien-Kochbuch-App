class Rating {
  final int userId;
  final double stars;
  final String? comment;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Rating({
    required this.userId,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      userId: json["user_id"],
      stars: json["stars"],
      comment: json["comment"],
      createdAt: DateTime.tryParse(json["created_at"]) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"]) ?? DateTime.now(),
    );
  }
}
