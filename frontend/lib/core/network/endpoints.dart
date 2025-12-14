import 'package:frontend/config/app_config.dart';

class Endpoints {
  static String recipes = "/recipes";
  static String recipe(int recipeId) => "$recipes/$recipeId";

  static String usernotes = "/usernotes";
  static String usernotesRecipe(int recipeId) => "$usernotes/$recipeId";

  static String ratings = "/ratings";
  static String ratingsRecipe(int recipeId) => "$ratings/$recipeId";

  static String tags = "/tags";
  static String tag(int tagId) => "$tags/$tagId";

  static String images = "/images";
  static String image(String filename) => "$images/$filename";
  static String imageHost(String filename) => "${AppConfig.baseUrl}$images/$filename";
}