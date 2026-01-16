import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  int id;
  String? name;
  String? email;
  int? avatarId;
  String role;

  @JsonKey(includeToJson: false)
  DateTime? createdAt;
  @JsonKey(includeToJson: false)
  DateTime? updatedAt;

  User({
    required this.id,
    this.name,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
