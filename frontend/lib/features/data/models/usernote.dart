class UserNote {
  final int userId;
  final String text;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserNote({required this.userId, required this.text, required this.createdAt, required this.updatedAt});

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      userId: json["user_id"],
      text: json["text"],
      createdAt: DateTime.tryParse(json["created_at"]) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"]) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "text": text,
    };
  }
}
