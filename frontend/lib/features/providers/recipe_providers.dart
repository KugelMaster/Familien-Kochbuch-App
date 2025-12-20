import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/services/image_service.dart';
import 'package:frontend/features/data/services/recipe_service.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RecipeService(client);
});

final imageServiceProvider = Provider<ImageService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ImageService(client);
});

///////////////////////////////////////////////////////////////////////////////

final recipeCache = Provider((_) => <int, Recipe>{});

Future<int> createNewRecipe(WidgetRef ref, Recipe recipe) async {
  final imageService = ref.read(imageServiceProvider);
  final recipeService = ref.read(recipeServiceProvider);

  if (recipe.image != null) {
    recipe.imageId = await imageService.sendImage(recipe.image!);
  }

  final (id, created) = await recipeService.createRecipe(recipe);
  created.image = recipe.image;
  ref.read(recipeCache)[id] = created;

  return id;
}

final recipesProvider = FutureProvider<List<RecipeSimple>>((ref) async {
  // TODO: Caching for simple recipe list too

  final service = ref.watch(recipeServiceProvider);
  return service.getAllSimple();
});

final recipeProvider =
    AsyncNotifierProvider.family<RecipeNotifier, Recipe, int>(
      RecipeNotifier.new,
    );

class RecipeNotifier extends AsyncNotifier<Recipe> {
  final int recipeId;

  late final cache = ref.watch(recipeCache);

  RecipeNotifier(this.recipeId);

  @override
  Future<Recipe> build() async {
    final cached = cache[recipeId];

    if (cached != null) {
      return cached;
    }

    final fetched = await ref.read(recipeServiceProvider).getById(recipeId);
    cache[recipeId] = fetched;
    return fetched;
  }

  void setFromExternal(Recipe recipe) {
    state = AsyncData(recipe);
  }

  Future<void> updateRecipe(RecipePatch patch) async {
    try {
      final imageService = ref.read(imageServiceProvider);
      final recipeService = ref.read(recipeServiceProvider);

      if (patch.image != null) {
        patch.imageId = await imageService.sendImage(patch.image!);
      }

      final updated = await recipeService.updateRecipe(recipeId, patch);
      updated.image = patch.image;

      cache[recipeId] = updated;

      state = AsyncData(updated);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteRecipe() async {
    await ref.read(recipeServiceProvider).deleteRecipe(recipeId);

    cache.remove(recipeId);

    ref.invalidateSelf();
  }
}
