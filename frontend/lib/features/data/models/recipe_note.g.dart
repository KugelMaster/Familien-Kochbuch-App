// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeNote _$RecipeNoteFromJson(Map<String, dynamic> json) => RecipeNote(
  id: (json['id'] as num).toInt(),
  recipeId: (json['recipe_id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RecipeNoteToJson(RecipeNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipe_id': instance.recipeId,
      'user_id': instance.userId,
      'content': instance.content,
    };
