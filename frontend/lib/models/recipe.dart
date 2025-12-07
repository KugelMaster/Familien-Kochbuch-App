class Recipe {
  final String title;
  final List<String>? tags;
  final String? image;
  final String? description;
  final double? timePrep;
  final double? timeTotal;
  final double? portions;
  final String? recipeUrl;

  final List<Ingredient> ingredients;
  final List<Nutrition>? nutritions;
  final List<UserNote>? usernotes;
  final List<Rating>? ratings;

  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe(
    this.title,
    this.tags,
    this.image,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUrl,
    this.ingredients,
    this.nutritions,
    this.usernotes,
    this.ratings,
    this.createdAt,
    this.updatedAt,
  );
}

class Ingredient {
  final String name;
  final String? amount;
  final String? unit;

  const Ingredient(this.name, this.amount, this.unit);
}

class Nutrition {
  final String name;
  final String? amount;
  final String? unit;

  const Nutrition(this.name, this.amount, this.unit);
}

class UserNote {
  final int userId;
  final String text;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserNote(this.userId, this.text, this.createdAt, this.updatedAt);
}

class Rating {
  final int userId;
  final double stars;
  final String? comment;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Rating(
    this.userId,
    this.stars,
    this.comment,
    this.createdAt,
    this.updatedAt,
  );
}
