import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/models/tag.dart';

class TagService {
  final ApiClient _client;

  TagService(this._client);

  Future<List<Tag>> getTags() async {
    final response = await _client.dio.get(Endpoints.tags);

    if (response.statusCode != 200) {
      throw Exception("Failed to get tags");
    }

    final data = response.data as List;

    return data.map((json) => Tag.fromJson(json)).toList();
  }

  Future<Tag> getById(int id) async {
    final response = await _client.dio.get(Endpoints.tag(id));

    if (response.statusCode != 200) {
      throw Exception("Failed to get tag");
    }

    return Tag.fromJson(response.data);
  }

  Future<Tag> createTag(String tagName) async {
    final response = await _client.dio.post(Endpoints.createTag(tagName));

    if (response.statusCode != 201) {
      throw Exception("Failed to create new tag");
    }

    return Tag.fromJson(response.data);
  }

  Future<Tag> renameTag(int id, String tagName) async {
    final response = await _client.dio.patch(Endpoints.renameTag(id, tagName));

    if (response.statusCode != 200) {
      throw Exception("Failed to rename tag");
    }

    return Tag.fromJson(response.data);
  }

  Future<void> deleteTag(int id) async {
    final response = await _client.dio.patch(Endpoints.tag(id));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete tag");
    }
  }

  Future<List<RecipeSimple>> getRecipesByTag(int tagId) async {
    final response = await _client.dio.get(Endpoints.recipesByTag(tagId));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch recipes by tag");
    }

    final data = response.data as List;

    return data.map((json) => RecipeSimple.fromJson(json)).toList();
  }
}
