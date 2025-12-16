import 'package:frontend/features/data/models/ingredient.dart';
import 'package:frontend/features/data/models/nutrition.dart';
import 'package:frontend/features/data/models/rating.dart';
import 'package:frontend/features/data/models/usernote.dart';
import 'package:image_picker/image_picker.dart';

class Recipe {
  String title;
  List<String>? tags;
  int? imageId;
  String? description;
  int? timePrep;
  int? timeTotal;
  double? portions;
  String? recipeUri;

  List<Ingredient>? ingredients;
  List<Nutrition>? nutritions;
  List<UserNote>? usernotes;
  List<Rating>? ratings;

  DateTime? createdAt;
  DateTime? updatedAt;

  /// Könnte Probleme mit copyWith() verursachen!
  XFile? image;

  Recipe({
    required this.title,
    this.tags,
    this.imageId,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUri,
    this.ingredients,
    this.nutritions,
    this.usernotes,
    this.ratings,
    this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<T> toList<T>(dynamic data, T Function(Map<String, dynamic> itemJson) fromJson) {
      if (data is! List) return [];

      return data.cast<Map<String, dynamic>>().map(fromJson).toList();
    }

    return Recipe(
      title: json["title"] as String,
      tags: List<String>.from(json["tags"] ?? []),
      imageId: json["image_id"] as int?,
      description: json["description"] as String?,

      timePrep: json["time_prep"] as int?,
      timeTotal: json["time_total"] as int?,
      portions: json["portions"] as double?,
      recipeUri: json["recipe_uri"] as String?,

      ingredients: toList(json["ingredients"], Ingredient.fromJson),
      nutritions: toList(json["nutritions"], Nutrition.fromJson),
      usernotes: toList(json["user_notes"], UserNote.fromJson),
      ratings: toList(json["ratings"], Rating.fromJson),

      createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
    };

    if (tags != null) data["tags"] = tags;
    if (imageId != null) data["image_id"] = imageId;
    if (description != null) data["description"] = description;
    if (timePrep != null) data["time_prep"] = timePrep;
    if (timeTotal != null) data["time_total"] = timeTotal;
    if (portions != null) data["portions"] = portions;
    if (recipeUri != null) data["recipe_uri"] = recipeUri;
    if (ingredients != null) data["ingredients"] = ingredients!.map((ing) => ing.toJson()).toList();
    if (nutritions != null) data["nutritions"] = nutritions!.map((nut) => nut.toJson()).toList();
    if (usernotes != null) data["user_notes"] = usernotes!.map((note) => note.toJson()).toList();
    if (ratings != null) data["ratings"] = ratings!.map((rat) => rat.toJson()).toList();

    return data;
  }
}

class RecipeSimple {
  int id;
  String title;

  RecipeSimple({
    required this.id,
    required this.title,
  });

  factory RecipeSimple.fromJson(Map<String, dynamic> json) {
    return RecipeSimple(
      id: json["id"] as int,
      title: json["title"] as String,
    );
  }
}

class RecipeUpdate {
  String? title;
  int? imageId;
  String? description;
  int? timePrep;
  int? timeTotal;
  double? portions;
  String? recipeUri;

  RecipeUpdate({
    this.title,
    this.imageId,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUri,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (title != null) data["title"] = title;
    if (imageId != null) data["image_id"] = imageId;
    if (description != null) data["description"] = description;
    if (timePrep != null) data["time_prep"] = timePrep;
    if (timeTotal != null) data["time_total"] = timeTotal;
    if (portions != null) data["portions"] = portions;
    if (recipeUri != null) data["recipe_uri"] = recipeUri;

    return data;
  }
}
