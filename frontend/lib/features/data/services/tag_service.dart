import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/features/data/models/tag.dart';

class TagService {
  final ApiClient _client;

  TagService(this._client);

  Future<List<Tag>> getTags() async {
    final response = await _client.dio.get(Endpoints.tags);

    if (response.data == null) {
      print("Error when fetching tags: ${response.statusCode}");
      throw Exception("Failed to get tags");
    }

    final data = response.data as List;

    return data.map((json) => Tag.fromJson(json)).toList();
  }

  Future<Tag> createTag(String tagName) async {
    final response = await _client.dio.post(Endpoints.createTag(tagName));

    if (response.data == null || response.statusCode != 200) {
      print("Error when creating new tag: ${response.statusCode}");
      throw Exception("Failed to create new tag");
    }

    return Tag.fromJson(response.data);
  }
}
