import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  int id;
  String name;
  String? email;
  int? avatarId;
  String role;

  @JsonKey(includeToJson: false)
  DateTime? createdAt;
  @JsonKey(includeToJson: false)
  DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    this.email,
    this.avatarId,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserSimple {
  int id;
  String name;
  int? avatarId;

  UserSimple({required this.id, required this.name, this.avatarId});

  factory UserSimple.fromJson(Map<String, dynamic> json) =>
      _$UserSimpleFromJson(json);

  Map<String, dynamic> toJson() => _$UserSimpleToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UserPatch {
  String? username;
  String? email;
  int? avatarId;
  String? role;

  UserPatch({this.username, this.email, this.avatarId, this.role});

  factory UserPatch.fromJson(Map<String, dynamic> json) =>
      _$UserPatchFromJson(json);

  Map<String, dynamic> toJson() => _$UserPatchToJson(this);
}
