class Ingredient {
  final String name;
  final double? amount;
  final String? unit;

  const Ingredient({required this.name, this.amount, this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json["name"],
      amount: double.parse(json["amount"]),
      unit: json["unit"],
    );
  }
}
