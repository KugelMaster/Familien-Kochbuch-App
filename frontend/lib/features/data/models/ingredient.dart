class Ingredient {
  final String name;
  final double? amount;
  final String? unit;

  const Ingredient({required this.name, this.amount, this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json["name"],
      amount: json["amount"],
      unit: json["unit"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "name": name,
    };

    if (amount != null) data["amount"] = amount;
    if (unit != null) data["unit"] = unit;

    return data;
  }
}
