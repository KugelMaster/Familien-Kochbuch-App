class Recipe {
  final String title;
  final List<String>? tags;
  final String? image;
  final String? description;
  final int? timePrep;
  final int? timeTotal;
  final double? portions;
  final String? recipeUri;

  final List<Ingredient> ingredients;
  final List<Nutrition>? nutritions;
  final List<UserNote>? usernotes;
  final List<Rating>? ratings;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.title,
    this.tags,
    this.image,
    this.description,
    this.timePrep,
    this.timeTotal,
    this.portions,
    this.recipeUri,
    required this.ingredients,
    this.nutritions,
    this.usernotes,
    this.ratings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json["title"],
      tags: List<String>.from(json["tags"]),
      image: json["image"],
      description: json["description"],
      timePrep: json["time_prep"],
      timeTotal: json["time_total"],
      portions: json["portions"],
      recipeUri: json["recipe_uri"],
      ingredients: List<Map<String, dynamic>>.from(json["ingredients"]).map((json) => Ingredient.fromJson(json)).toList(),
      nutritions: List<Map<String, dynamic>>.from(json["nutritions"]).map((json) => Nutrition.fromJson(json)).toList(),
      usernotes: List<Map<String, dynamic>>.from(json["user_notes"] ?? []).map((json) => UserNote.fromJson(json)).toList(),
      ratings: List<Map<String, dynamic>>.from(json["ratings"]).map((json) => Rating.fromJson(json)).toList(),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}

class Ingredient {
  final String name;
  final String? amount;
  final String? unit;

  const Ingredient({required this.name, this.amount, this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json["name"],
      amount: json["amount"],
      unit: json["unit"],
    );
  }
}

class Nutrition {
  final String name;
  final String? amount;
  final String? unit;

  const Nutrition({required this.name, this.amount, this.unit});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      name: json["name"],
      amount: json["amount"],
      unit: json["unit"],
    );
  }
}

class UserNote {
  final int userId;
  final String text;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserNote({required this.userId, required this.text, required this.createdAt, required this.updatedAt});

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      userId: json["user_id"],
      text: json["text"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}

class Rating {
  final int userId;
  final double stars;
  final String? comment;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Rating({
    required this.userId,
    required this.stars,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      userId: json["user_id"],
      stars: json["stars"],
      comment: json["comment"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}
