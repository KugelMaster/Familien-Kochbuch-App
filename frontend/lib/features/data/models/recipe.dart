import 'package:frontend/features/data/models/ingredient.dart';
import 'package:frontend/features/data/models/nutrition.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Recipe {
  String title;
  List<Tag> tags;

  /// If [Recipe.imageId] is null, but [Recipe.image] is not null, then the image is new and should be sent to the backend immediately to retrieve a new imageId.
  int? imageId;
  String? description;
  int? timePrep;
  int? timeTotal;
  double? portions;
  String? recipeUri;

  List<Ingredient> ingredients;
  List<Nutrition> nutritions;

  @JsonKey(includeToJson: false)
  DateTime? createdAt;
  @JsonKey(includeToJson: false)
  DateTime? updatedAt;

  /// Könnte Probleme mit copyWith() verursachen!
  @JsonKey(includeFromJson: false, includeToJson: false)
  XFile? image;

  Recipe({
    required this.title,
    this.tags = const [],
    this.imageId,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUri,
    this.ingredients = const [],
    this.nutritions = const [],
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable()
class RecipeSimple {
  int id;
  String title;

  RecipeSimple({required this.id, required this.title});

  factory RecipeSimple.fromJson(Map<String, dynamic> json) =>
      _$RecipeSimpleFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeSimpleToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class RecipePatch {
  String? title;
  List<int>? tags;
  int? imageId;
  String? description;
  int? timePrep;
  int? timeTotal;
  double? portions;
  String? recipeUri;

  List<Ingredient>? ingredients;
  List<Nutrition>? nutritions;

  @JsonKey(includeFromJson: false, includeToJson: false)
  XFile? image;

  RecipePatch({
    this.title,
    this.tags,
    this.imageId,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUri,
    this.ingredients,
    this.nutritions,
    this.image,
  });

  factory RecipePatch.fromJson(Map<String, dynamic> json) =>
      _$RecipePatchFromJson(json);

  Map<String, dynamic> toJson() => _$RecipePatchToJson(this);

  bool get isEmpty => [
    title,
    imageId,
    description,
    timePrep,
    timeTotal,
    portions,
    recipeUri,
    ingredients,
    nutritions,
    image,
  ].every((attr) => attr == null);
}
