import 'package:json_annotation/json_annotation.dart';

part 'usernote.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserNote {
  final int userId;
  final String text;

  @JsonKey(includeToJson: false)
  final DateTime createdAt;
  @JsonKey(includeToJson: false)
  final DateTime updatedAt;

  const UserNote({required this.userId, required this.text, required this.createdAt, required this.updatedAt});

  factory UserNote.fromJson(Map<String, dynamic> json) => _$UserNoteFromJson(json);

  Map<String, dynamic> toJson() => _$UserNoteToJson(this);
}
