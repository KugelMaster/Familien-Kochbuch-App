class Nutrition {
  final String name;
  final double? amount;
  final String? unit;

  const Nutrition({required this.name, this.amount, this.unit});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
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
