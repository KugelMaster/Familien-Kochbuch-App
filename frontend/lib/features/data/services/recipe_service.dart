import 'package:dio/dio.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';

class RecipeService {
  final ApiClient _client;

  RecipeService(this._client);

  Future<List<Recipe>> getAll() async {
    final response = await _client.dio.get(Endpoints.recipes);
    final data = response.data as List;

    return data.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<RecipeSimple>> getAllSimple() async {
    final response = await _client.dio.get(Endpoints.recipesSimple);
    final data = response.data as List;

    return data.map((json) => RecipeSimple.fromJson(json)).toList();
  }

  Future<Recipe> getById(int recipeId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      Endpoints.recipe(recipeId),
    );

    if (response.data == null) {
      print(
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
      print("Creating recipe failed: ${response.statusCode}");
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
      print("Update recipe failed: ${response.statusCode}");
      throw Exception("Failed to update recipe");
    }

    return Recipe.fromJson(response.data!);
  }

  Future<void> deleteRecipe(int recipeId) async {
    final response = await _client.dio.delete(Endpoints.recipe(recipeId));

    if (response.statusCode != 200) {
      print("Deleting recipe failed: ${response.statusCode}");
      throw Exception("Failed to delete recipe");
    }
  }
}
