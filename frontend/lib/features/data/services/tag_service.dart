import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/features/data/models/tag.dart';

class TagService {
  final ApiClient _client;

  TagService(this._client);

  Future<List<Tag>> getTags() async {
    final response = await _client.dio.get(Endpoints.tags);

    if (response.data == null) {
      logger.d(
        "Error when fetching tags: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to get tags");
    }

    final data = response.data as List;

    return data.map((json) => Tag.fromJson(json)).toList();
  }

  Future<Tag> getById(int id) async {
    final response = await _client.dio.get(Endpoints.tag(id));

    if (response.data == null || response.statusCode != 200) {
      logger.d(
        "Error when fetching tag: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to get tag");
    }

    return Tag.fromJson(response.data);
  }

  Future<Tag> createTag(String tagName) async {
    final response = await _client.dio.post(Endpoints.createTag(tagName));

    if (response.data == null || response.statusCode != 200) {
      logger.d(
        "Error when creating new tag: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to create new tag");
    }

    return Tag.fromJson(response.data);
  }

  Future<Tag> renameTag(int id, String tagName) async {
    final response = await _client.dio.patch(Endpoints.renameTag(id, tagName));

    if (response.data == null || response.statusCode != 200) {
      logger.d(
        "Error when renaming tag: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to rename tag");
    }

    return Tag.fromJson(response.data);
  }

  Future<void> deleteTag(int id) async {
    final response = await _client.dio.patch(Endpoints.tag(id));

    if (response.data == null || response.statusCode != 200) {
      logger.d(
        "Error when deleting tag: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to delete tag");
    }
  }
}
