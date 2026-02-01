import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/features/data/models/recipe_note.dart';

class RecipeNoteService {
  final ApiClient _client;

  RecipeNoteService(this._client);

  Future<RecipeNote> getById(int noteId) async {
    final response = await _client.dio.get(Endpoints.recipeNote(noteId));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch recipe note");
    }

    return RecipeNote.fromJson(response.data!);
  }

  Future<List<RecipeNote>> getByRecipeId(int recipeId) async {
    final response = await _client.dio.get(Endpoints.recipeNotesRecipe(recipeId));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch recipe notes");
    }

    final data = response.data as List;

    return data.map((json) => RecipeNote.fromJson(json)).toList();
  }

  Future<RecipeNote> createRecipeNote(RecipeNoteCreate note) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      Endpoints.recipeNotes,
      data: note.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create recipe note");
    }

    return RecipeNote.fromJson(response.data!);
  }

  Future<RecipeNote> updateRecipeNote(int noteId, String content) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      Endpoints.recipeNote(noteId),
      data: {"content": content},
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update recipe note");
    }

    return RecipeNote.fromJson(response.data!);
  }

  Future<void> deleteRecipeNote(int noteId) async {
    final response = await _client.dio.delete(Endpoints.recipeNote(noteId));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete recipe note");
    }
  }
}
