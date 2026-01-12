class Endpoints {
  static String auth = "/auth";
  static String me = "$auth/me";
  static String getToken = "$auth/token";
  static String changePassword = "$me/password";

  static String users = "/users";
  static String signup = "$users/signup";
  static String user(int userId) => "$users/$userId";

  static String recipes = "/recipes";
  static String recipesSimple = "$recipes/simple";
  static String recipe(int recipeId) => "$recipes/$recipeId";
  static String searchRecipes(
    String query, [
    int maxResults = 10,
    int? userId,
  ]) => Uri(
    path: "/search",
    queryParameters: {
      "query": query,
      "max_results": maxResults.toString(),
      if (userId != null) "user_id": userId,
    },
  ).toString();

  static String recipeNotes = "/recipe-notes";
  static String recipeNote(int noteId) => "$recipeNotes/note/$noteId";
  static String recipeNotesRecipe(int recipeId) => "$recipeNotes/$recipeId";

  static String ratings = "/ratings";
  static String rating(int ratingId) => "$ratings/rating/$ratingId";
  static String ratingsRecipe(int recipeId) => "$ratings/$recipeId";
  static String ratingAvgStars(int recipeId) => "$ratings/$recipeId/average";

  static String tags = "/tags";
  static String createTag(String name) =>
      Uri(path: tags, queryParameters: {"tag_name": name}).toString();
  static String tag(int tagId) => "$tags/$tagId";
  static String renameTag(int id, String name) =>
      Uri(path: "$tags/$id", queryParameters: {"new_name": name}).toString();
  static String recipesByTag(int tagId) => "$tags/$tagId/recipes";

  static String images = "/images";
  static String image(int imageId) => "$images/$imageId";
}
