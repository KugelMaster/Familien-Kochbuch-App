import 'package:frontend/features/data/models/ingredient.dart';
import 'package:frontend/features/data/models/nutrition.dart';
import 'package:frontend/features/data/models/rating.dart';
import 'package:frontend/features/data/models/usernote.dart';

class Recipe {
  final String title;
  final List<String>? tags;
  final String? image;
  final String? description;
  final int? timePrep;
  final int? timeTotal;
  final double? portions;
  final String? recipeUri;

  final List<Ingredient> ingredients;
  final List<Nutrition>? nutritions;
  final List<UserNote>? usernotes;
  final List<Rating>? ratings;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.title,
    this.tags,
    this.image,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUri,
    required this.ingredients,
    this.nutritions,
    this.usernotes,
    this.ratings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<T> toList<T>(dynamic data, T Function(Map<String, dynamic> itemJson) fromJson) {
      if (data is! List) return [];

      return data.cast<Map<String, dynamic>>().map(fromJson).toList();
    }

    return Recipe(
      title: json["title"] as String,
      tags: List<String>.from(json["tags"] ?? []),
      image: json["image"] as String?,
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
}
