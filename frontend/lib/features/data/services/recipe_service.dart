import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<int> sendImage(XFile image) async {
    final file = await MultipartFile.fromFile(image.path, filename: image.name);
    final formData = FormData.fromMap({"file": file});

    final response = await _client.dio.post<Map>(
      Endpoints.images,
      data: formData,
      options: Options(
        responseType: ResponseType.json,
        contentType: image.mimeType,
      ),
    );

    return response.data?["id"] ?? -1;
  }

  Future<XFile> getImage(int imageId) async {
    final response = await _client.dio.get<List<int>>(
      Endpoints.image(imageId),
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = response.data;

    if (bytes == null) {
      print(
        "Recieving Image failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to load image");
    }

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/image.jpg");

    await file.writeAsBytes(bytes);

    return XFile(file.path);

    // Shorter version, but doesn't work if the file is requested via path :-(
    //return XFile.fromData(
    //  Uint8List.fromList(bytes),
    //  mimeType: response.headers.value(Headers.contentTypeHeader) ?? "image/jpeg",
    //);
  }
}
