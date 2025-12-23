import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Rating {
  int? id;
  int userId;
  double stars;
  String? comment;

  @JsonKey(includeToJson: false)
  DateTime? createdAt;
  @JsonKey(includeToJson: false)
  DateTime? updatedAt;

  Rating({
    this.id,
    required this.userId,
    required this.stars,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
