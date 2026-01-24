import 'package:json_annotation/json_annotation.dart';

part 'recipe_note.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RecipeNote {
  int id;
  int recipeId;
  int? userId;
  String content;

  @JsonKey(includeToJson: false)
  DateTime createdAt;
  @JsonKey(includeToJson: false)
  DateTime updatedAt;

  RecipeNote({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeNote.fromJson(Map<String, dynamic> json) =>
      _$RecipeNoteFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeNoteToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RecipeNoteCreate {
  int recipeId;
  String content;

  RecipeNoteCreate({
    required this.recipeId,
    required this.content,
  });

  factory RecipeNoteCreate.fromJson(Map<String, dynamic> json) =>
      _$RecipeNoteCreateFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeNoteCreateToJson(this);
}
