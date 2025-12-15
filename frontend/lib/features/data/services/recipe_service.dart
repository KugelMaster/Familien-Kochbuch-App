import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
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
      print("Get recipe by ID failed: ${response.statusCode} ${response.statusMessage}");
      throw Exception("Failed to load recipe");
    }

    return Recipe.fromJson(response.data!);
  }

  Future<Recipe> updateRecipe(int recipeId, RecipeUpdate updatedRecipe) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      Endpoints.recipe(recipeId),
      data: updatedRecipe.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.data == null) {
      print(
        "Update recipe failed: ${response.statusCode} ${response.statusMessage}",
      );
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

    return XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: response.headers.value(Headers.contentTypeHeader) ?? "image/jpeg",
    );

    /*
    // Some APIs need XFile with a file path, this is an alternative way to get it:

    import 'dart:io';
    import 'dart:typed_data';
    import 'package:path_provider/path_provider.dart';
    import 'package:cross_file/cross_file.dart';

    Future<XFile> loadImageAsXFileViaFile(String url) async {
      final bytes = await loadImageBytes(url);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/image.jpg');

      await file.writeAsBytes(bytes);

      return XFile(file.path);
    }
    */
  }
}
