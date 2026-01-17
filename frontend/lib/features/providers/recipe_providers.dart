import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/services/recipe_note_service.dart';
import 'package:frontend/features/data/services/recipe_service.dart';
import 'package:frontend/features/providers/image_providers.dart';
import 'package:frontend/features/providers/tag_providers.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RecipeService(client);
});

final recipeNoteServiceProvider = Provider<RecipeNoteService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RecipeNoteService(client);
});

final recipeRepositoryInvalidationProvider =
    NotifierProvider<RecipeRepositoryInvalidationNotifier, int>(
      RecipeRepositoryInvalidationNotifier.new,
    );

class RecipeRepositoryInvalidationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state++;
}

final recipeRepositoryProvider =
    NotifierProvider<RecipeRepositoryNotifier, Map<int, Recipe>>(
      RecipeRepositoryNotifier.new,
    );

class RecipeRepositoryNotifier extends Notifier<Map<int, Recipe>> {
  late final _recipeService = ref.read(recipeServiceProvider);
  ImageRepositoryNotifier get _imageRepo => ref.read(imageRepositoryProvider.notifier);
  late final _tagService = ref.read(tagServiceProvider);

  @override
  Map<int, Recipe> build() {
    ref.watch(recipeRepositoryInvalidationProvider);
    return {};
  }

  Future<Recipe> getById(int recipeId) async {
    final cached = state[recipeId];
    if (cached != null) return cached;

    final fetched = await _recipeService.getById(recipeId);

    if (fetched.imageId != null) {
      fetched.image = await _imageRepo.getImage(fetched.imageId!);
    }

    state = {...state, recipeId: fetched};
    return fetched;
  }

  Future<List<RecipeSimple>> getByTag(int tagId) async {
    // FIXME: Not enough information to certainly know that we have every recipe of backend cached :-(
    //final cached = state.values.where((r) => r.tags.any((t) => t.id == tagId)).toList();
    //if (cached.isNotEmpty) return cached;

    final fetched = await _tagService.getRecipesByTag(tagId);

    return fetched;
  }

  Future<List<RecipeSimple>> fetchAllSimple() async {
    return _recipeService.getAllSimple();
  }

  Future<int> createRecipe(Recipe recipe) async {
    if (recipe.image != null) {
      recipe.imageId = await _imageRepo.uploadImage(recipe.image!, "recipe");
    }

    final (id, created) = await _recipeService.createRecipe(recipe);
    created.image = recipe.image;

    state = {...state, id: created};
    return id;
  }

  Future<Recipe> updateRecipe(int recipeId, RecipePatch patch) async {
    final image = patch.image ?? state[recipeId]?.image;

    if (patch.image != null) {
      patch.imageId = await _imageRepo.uploadImage(patch.image!, "recipe");
    }

    final updated = await _recipeService.updateRecipe(recipeId, patch);
    updated.image = image;

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

final recipeSimpleListProvider = FutureProvider<List<RecipeSimple>>((
  ref,
) async {
  ref.watch(recipeRepositoryInvalidationProvider);
  return ref.read(recipeRepositoryProvider.notifier).fetchAllSimple();
});

final recipeProvider = FutureProvider.family<Recipe, int>((
  ref,
  recipeId,
) async {
  ref.watch(recipeRepositoryProvider);
  return ref.read(recipeRepositoryProvider.notifier).getById(recipeId);
});

final recipesByTagProvider = FutureProvider.family<List<RecipeSimple>, int>((
  ref,
  tagId,
) {
  ref.watch(recipeRepositoryProvider);
  return ref.read(recipeRepositoryProvider.notifier).getByTag(tagId);
});

void invalidateRepository(WidgetRef ref) {
  ref.read(recipeRepositoryInvalidationProvider.notifier).trigger();
}
