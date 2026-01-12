import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Rating {
  int id;
  int recipeId;
  int userId;
  double stars;
  String? comment;

  @JsonKey(includeToJson: false)
  DateTime createdAt;
  @JsonKey(includeToJson: false)
  DateTime updatedAt;

  Rating({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RatingCreate {
  int recipeId;
  double stars;
  String? comment;

  RatingCreate({
    required this.recipeId,
    required this.stars,
    this.comment,
  });

  factory RatingCreate.fromJson(Map<String, dynamic> json) =>
      _$RatingCreateFromJson(json);

  Map<String, dynamic> toJson() => _$RatingCreateToJson(this);
}

@JsonSerializable(includeIfNull: false)
class RatingPatch {
  @JsonKey(includeToJson: false)
  int id;
  @JsonKey(includeToJson: false)
  int recipeId;

  double stars;
  String? comment;

  RatingPatch({
    required this.id,
    required this.recipeId,
    required this.stars,
    this.comment,
  });

  factory RatingPatch.fromJson(Map<String, dynamic> json) =>
      _$RatingPatchFromJson(json);

  Map<String, dynamic> toJson() => _$RatingPatchToJson(this);
}
