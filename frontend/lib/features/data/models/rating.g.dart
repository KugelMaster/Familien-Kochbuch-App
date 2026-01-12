// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
  id: (json['id'] as num).toInt(),
  recipeId: (json['recipe_id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  stars: (json['stars'] as num).toDouble(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
  'id': instance.id,
  'recipe_id': instance.recipeId,
  'user_id': instance.userId,
  'stars': instance.stars,
  'comment': instance.comment,
};

RatingCreate _$RatingCreateFromJson(Map<String, dynamic> json) => RatingCreate(
  recipeId: (json['recipe_id'] as num).toInt(),
  stars: (json['stars'] as num).toDouble(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$RatingCreateToJson(RatingCreate instance) =>
    <String, dynamic>{
      'recipe_id': instance.recipeId,
      'stars': instance.stars,
      'comment': instance.comment,
    };

RatingPatch _$RatingPatchFromJson(Map<String, dynamic> json) => RatingPatch(
  id: (json['id'] as num).toInt(),
  recipeId: (json['recipeId'] as num).toInt(),
  stars: (json['stars'] as num).toDouble(),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$RatingPatchToJson(RatingPatch instance) =>
    <String, dynamic>{'stars': instance.stars, 'comment': ?instance.comment};
