import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/features/data/models/rating.dart';

class RatingService {
  final ApiClient _client;

  RatingService(this._client);

  Future<Rating> getById(int ratingId) async {
    final response = await _client.dio.get(Endpoints.rating(ratingId));

    if (response.data == null) {
      logger.d(
        "Fetching rating failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to fetch rating");
    }

    return Rating.fromJson(response.data!);
  }

  Future<List<Rating>> getByRecipeId(int recipeId) async {
    final response = await _client.dio.get(Endpoints.ratingsRecipe(recipeId));

    if (response.data == null) {
      logger.d(
        "Fetching ratings failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to fetch ratings");
    }

    final data = response.data as List;

    return data.map((json) => Rating.fromJson(json)).toList();
  }

  Future<(double, int)> getAverageStars(int recipeId) async {
    final response = await _client.dio.get(Endpoints.ratingAvgStars(recipeId));

    if (response.data == null) {
      logger.d(
        "Fetching average stars failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to fetch average stars");
    }

    Map<String, dynamic> data = response.data;

    return (data["average_stars"] as double, data["total_ratings"] as int);
  }

  Future<Rating> createRating(RatingCreate rating) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      Endpoints.ratings,
      data: rating.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.data == null) {
      logger.d(
        "Create rating failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to create rating");
    }

    return Rating.fromJson(response.data!);
  }

  Future<Rating> updateRating(RatingPatch patch) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      Endpoints.rating(patch.id),
      data: patch.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.data == null) {
      logger.d(
        "Updateing rating failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to update rating");
    }

    return Rating.fromJson(response.data!);
  }

  Future<void> deleteRating(int ratingId) async {
    final response = await _client.dio.delete(Endpoints.rating(ratingId));

    if (response.statusCode != 200) {
      logger.d(
        "Deleting rating failed: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to delete rating");
    }
  }
}
