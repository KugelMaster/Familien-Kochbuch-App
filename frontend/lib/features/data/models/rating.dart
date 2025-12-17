import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Rating {
  final int userId;
  final double stars;
  final String? comment;

  @JsonKey(includeToJson: false)
  final DateTime createdAt;
  @JsonKey(includeToJson: false)
  final DateTime updatedAt;

  const Rating({
    required this.userId,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
