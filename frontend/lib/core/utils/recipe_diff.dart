import 'package:flutter/foundation.dart';
import 'package:frontend/features/data/models/recipe.dart';

class RecipeDiff {
  static RecipePatch from(Recipe oldR, Recipe newR) => RecipePatch(
    title: oldR.title != newR.title ? newR.title : null,
    imageId: oldR.imageId != newR.imageId ? newR.imageId : null,
    description: oldR.description != newR.description
        ? newR.description
        : null,
    timePrep: oldR.timePrep != newR.timePrep ? newR.timePrep : null,
    timeTotal: oldR.timeTotal != newR.timeTotal ? newR.timeTotal : null,
    portions: oldR.portions != newR.portions ? newR.portions : null,
    recipeUri: oldR.recipeUri != newR.recipeUri ? newR.recipeUri : null,
    ingredients: !listEquals(oldR.ingredients, newR.ingredients)
        ? newR.ingredients
        : null,
    nutritions: !listEquals(oldR.nutritions, newR.nutritions)
        ? newR.nutritions
        : null,
  );
}