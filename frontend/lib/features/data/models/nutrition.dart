class Nutrition {
  final String name;
  final double? amount;
  final String? unit;

  const Nutrition({required this.name, this.amount, this.unit});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      name: json["name"],
      amount: double.parse(json["amount"]),
      unit: json["unit"],
    );
  }
}
