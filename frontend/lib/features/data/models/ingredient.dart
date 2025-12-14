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
