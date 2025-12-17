import 'package:json_annotation/json_annotation.dart';

part 'nutrition.g.dart';

@JsonSerializable()
class Nutrition {
  final String name;
  final double? amount;
  final String? unit;

  const Nutrition({required this.name, this.amount, this.unit});

  factory Nutrition.fromJson(Map<String, dynamic> json) => _$NutritionFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is! Nutrition) return false;

    return name == other.name && amount == other.amount && unit == other.unit;
  }

  @override
  int get hashCode => Object.hash(name, amount, unit);
}
