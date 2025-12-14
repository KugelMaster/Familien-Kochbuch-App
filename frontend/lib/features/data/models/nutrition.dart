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
