class Endpoints {
  static String recipes = "/recipes";
  static String recipesSimple = "$recipes/simple";
  static String recipe(int recipeId) => "$recipes/$recipeId";

  static String recipeNotes = "/recipe-notes";
  static String recipeNote(int noteId) => "$recipeNotes/note/$noteId";
  static String recipeNotesRecipe(int recipeId) => "$recipeNotes/$recipeId";

  static String ratings = "/ratings";
  static String rating(int ratingId) => "$ratings/rating/$ratingId";
  static String ratingsRecipe(int recipeId) => "$ratings/$recipeId";

  static String tags = "/tags";
  static String createTag(String name) => "$tags?tag_name=$name";
  static String tag(int tagId) => "$tags/$tagId";
  static String renameTag(int id, String name) => "$tags/$id?new_name=$name";

  static String images = "/images";
  static String image(int imageId) => "$images/$imageId";
}