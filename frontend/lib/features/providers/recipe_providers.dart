import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/services/recipe_service.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RecipeService(client);
});


final recipesProvider = FutureProvider<List<RecipeSimple>>((ref) async {
  final service = ref.watch(recipeServiceProvider);
  return service.getAllSimple();
});
