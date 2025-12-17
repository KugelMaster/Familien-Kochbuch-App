// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
  userId: (json['user_id'] as num).toInt(),
  stars: (json['stars'] as num).toDouble(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
  'user_id': instance.userId,
  'stars': instance.stars,
  'comment': instance.comment,
};
