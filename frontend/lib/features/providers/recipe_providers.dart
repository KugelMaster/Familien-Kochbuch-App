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


final recipeRepositoryInvalidationProvider = NotifierProvider<RecipeRepositoryInvalidationNotifier, int>(RecipeRepositoryInvalidationNotifier.new);
class RecipeRepositoryInvalidationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state++;
}


final recipeRepositoryProvider = NotifierProvider<RecipeRepositoryNotifier, Map<int, Recipe>>(RecipeRepositoryNotifier.new);
class RecipeRepositoryNotifier extends Notifier<Map<int, Recipe>> {
  late final RecipeService _recipeService = ref.read(recipeServiceProvider);
  late final ImageService _imageService = ref.read(imageServiceProvider);

  @override
  Map<int, Recipe> build() {
    ref.watch(recipeRepositoryInvalidationProvider);
    return {};
  }

  Future<Recipe> getById(int recipeId) async {
    final cached = state[recipeId];
    if (cached != null) return cached;

    final fetched = await _recipeService.getById(recipeId);
    state = {...state, recipeId: fetched};
    return fetched;
  }

  Future<List<RecipeSimple>> fetchAllSimple() async {
    return _recipeService.getAllSimple();
  }

  Future<int> createRecipe(Recipe recipe) async {
    if (recipe.image != null) {
      recipe.imageId = await _imageService.sendImage(recipe.image!);
    }

    final (id, created) = await _recipeService.createRecipe(recipe);
    created.image = recipe.image;

    state = {...state, id: created};
    return id;
  }

  Future<Recipe> updateRecipe(int recipeId, RecipePatch patch) async {
    if (patch.image != null) {
      patch.imageId = await _imageService.sendImage(patch.image!);
    }

    final updated = await _recipeService.updateRecipe(recipeId, patch);
    updated.image = patch.image;

    state = {...state, recipeId: updated};
    return updated;
  }

  Future<void> deleteRecipe(int recipeId) async {
    await _recipeService.deleteRecipe(recipeId);
    final newState = Map<int, Recipe>.from(state);
    newState.remove(recipeId);
    state = newState;
  }
}

Future<int> createNewRecipe(WidgetRef ref, Recipe recipe) async {
  return ref.read(recipeRepositoryProvider.notifier).createRecipe(recipe);
}

final recipesProvider = FutureProvider<List<RecipeSimple>>((ref) async {
  ref.watch(recipeRepositoryInvalidationProvider);
  return ref.read(recipeRepositoryProvider.notifier).fetchAllSimple();
});

final recipeByIdProvider = FutureProvider.family<Recipe, int>((ref, recipeId) async {
  ref.watch(recipeRepositoryInvalidationProvider);
  return ref.read(recipeRepositoryProvider.notifier).getById(recipeId);
});

void invalidateRepository(WidgetRef ref) {
  ref.read(recipeRepositoryInvalidationProvider.notifier).trigger();
}