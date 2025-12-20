// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  title: json['title'] as String,
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageId: (json['image_id'] as num?)?.toInt(),
  description: json['description'] as String?,
  timePrep: (json['time_prep'] as num?)?.toInt(),
  timeTotal: (json['time_total'] as num?)?.toInt(),
  portions: (json['portions'] as num?)?.toDouble(),
  recipeUri: json['recipe_uri'] as String?,
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  nutritions: (json['nutritions'] as List<dynamic>?)
      ?.map((e) => Nutrition.fromJson(e as Map<String, dynamic>))
      .toList(),
  usernotes: (json['usernotes'] as List<dynamic>?)
      ?.map((e) => UserNote.fromJson(e as Map<String, dynamic>))
      .toList(),
  ratings: (json['ratings'] as List<dynamic>?)
      ?.map((e) => Rating.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'title': instance.title,
  'tags': instance.tags,
  'image_id': instance.imageId,
  'description': instance.description,
  'time_prep': instance.timePrep,
  'time_total': instance.timeTotal,
  'portions': instance.portions,
  'recipe_uri': instance.recipeUri,
  'ingredients': instance.ingredients,
  'nutritions': instance.nutritions,
  'usernotes': instance.usernotes,
  'ratings': instance.ratings,
};

RecipeSimple _$RecipeSimpleFromJson(Map<String, dynamic> json) => RecipeSimple(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
);

Map<String, dynamic> _$RecipeSimpleToJson(RecipeSimple instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

RecipePatch _$RecipePatchFromJson(Map<String, dynamic> json) => RecipePatch(
  title: json['title'] as String?,
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  imageId: (json['image_id'] as num?)?.toInt(),
  description: json['description'] as String?,
  timePrep: (json['time_prep'] as num?)?.toInt(),
  timeTotal: (json['time_total'] as num?)?.toInt(),
  portions: (json['portions'] as num?)?.toDouble(),
  recipeUri: json['recipe_uri'] as String?,
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  nutritions: (json['nutritions'] as List<dynamic>?)
      ?.map((e) => Nutrition.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecipePatchToJson(RecipePatch instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'tags': ?instance.tags,
      'image_id': ?instance.imageId,
      'description': ?instance.description,
      'time_prep': ?instance.timePrep,
      'time_total': ?instance.timeTotal,
      'portions': ?instance.portions,
      'recipe_uri': ?instance.recipeUri,
      'ingredients': ?instance.ingredients,
      'nutritions': ?instance.nutritions,
    };
