import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/rating.dart';
import 'package:frontend/features/data/services/rating_service.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

final ratingServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return RatingService(client);
});

final ratingRepositoryProvider = NotifierProvider(RatingRepositoryProvider.new);

class RatingRepositoryProvider extends Notifier<Map<int, List<Rating>>> {
  late final RatingService _ratingService = ref.read(ratingServiceProvider);

  @override
  Map<int, List<Rating>> build() {
    ref.watch(recipeRepositoryInvalidationProvider);
    return {};
  }

  Future<List<Rating>> getByRecipeId(int recipeId) async {
    final cached = state[recipeId];
    if (cached != null) return cached;

    final ratings = await _ratingService.getByRecipeId(recipeId);
    state = {...state, recipeId: ratings};
    return ratings;
  }

  Future<Rating> createRating(RatingCreate rating) async {
    final created = await _ratingService.createRating(rating);

    final ratings = state[created.recipeId] ?? [];
    ratings.add(created);
    state = {...state, created.recipeId: ratings};

    return created;
  }

  Future<Rating> updateRating(RatingPatch patch) async {
    final updated = await _ratingService.updateRating(patch);

    final ratings = state[patch.recipeId] ?? [];
    final ratingIndex = ratings.indexWhere(
      (oldRating) => oldRating.id == patch.id,
    );
    if (ratingIndex != -1) {
      ratings[ratingIndex] = updated;
      state = {...state, patch.recipeId: ratings};
    }

    return updated;
  }

  Future<void> deleteRating(int recipeId, int ratingId) async {
    await _ratingService.deleteRating(ratingId);

    final ratings = state[recipeId] ?? [];
    ratings.removeWhere((rating) => rating.id == ratingId);
    state = {...state, recipeId: ratings};
  }
}

final ratingProvider = FutureProvider.family<List<Rating>, int>((
  ref,
  recipeId,
) async {
  ref.watch(ratingRepositoryProvider);
  return ref.read(ratingRepositoryProvider.notifier).getByRecipeId(recipeId);
});
