import 'package:dio/dio.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';

class RecipeService {
  final ApiClient _client;

  RecipeService(this._client);

  Future<List<Recipe>> getAll() async {
    final response = await _client.dio.get<List<dynamic>>(Endpoints.recipes);

    if (response.data == null) {
      logger.e(
        "Get all recipe failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to load all recipes");
    }

    return response.data!.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<RecipeSimple>> getAllSimple() async {
    final response = await _client.dio.get<List<dynamic>>(
      Endpoints.recipesSimple,
    );

    if (response.data == null) {
      logger.e(
        "Get recipes simple failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to load recipes simple");
    }

    return response.data!.map((json) => RecipeSimple.fromJson(json)).toList();
  }

  Future<Recipe> getById(int recipeId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      Endpoints.recipe(recipeId),
    );

    if (response.data == null) {
      logger.e(
        "Get recipe by ID failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to load recipe");
    }

    return Recipe.fromJson(response.data!);
  }

  Future<(int, Recipe)> createRecipe(Recipe recipe) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      Endpoints.recipes,
      data: recipe.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.data == null) {
      logger.e(
        "Creating recipe failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to create recipe");
    }

    return (response.data!["id"] as int, Recipe.fromJson(response.data!));
  }

  Future<Recipe> updateRecipe(int recipeId, RecipePatch patch) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      Endpoints.recipe(recipeId),
      data: patch.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.data == null) {
      logger.e(
        "Update recipe failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to update recipe");
    }

    return Recipe.fromJson(response.data!);
  }

  Future<void> deleteRecipe(int recipeId) async {
    final response = await _client.dio.delete(Endpoints.recipe(recipeId));

    if (response.statusCode != 200) {
      logger.e(
        "Deleting recipe failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to delete recipe");
    }
  }

  Future<List<RecipeSimple>> searchRecipes({
    required String query,
    int maxResults = 10,
    int? userId,
  }) async {
    final response = await _client.dio.get<List<dynamic>>(
      Endpoints.searchRecipes(query, maxResults, userId),
    );

    if (response.statusCode != 200) {
      logger.e(
        "Searching recipes failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to search recipes");
    }

    return response.data!.map((json) => RecipeSimple.fromJson(json)).toList();
  }
}
