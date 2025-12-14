import 'package:dio/dio.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:image_picker/image_picker.dart';

class RecipeService {
  final ApiClient _client;

  RecipeService(this._client);

  Future<List<Recipe>> getAll() async {
    final response = await _client.dio.get(Endpoints.recipes);
    final data = response.data as List;

    return data.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<String> sendImage(XFile image) async {
    final file = await MultipartFile.fromFile(image.path, filename: image.name);
    final formData = FormData.fromMap({
      "file": file,
    });

    final response = await _client.dio.post<String>(
      Endpoints.images,
      data: formData,
      options: Options(responseType: ResponseType.json, contentType: image.mimeType),
    );

    return response.data!;
  }
}
