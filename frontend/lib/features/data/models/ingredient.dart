import 'package:json_annotation/json_annotation.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String name;
  final double? amount;
  final String? unit;

  const Ingredient({required this.name, this.amount, this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is! Ingredient) return false;

    return name == other.name && amount == other.amount && unit == other.unit;
  }

  @override
  int get hashCode => Object.hash(name, amount, unit);
}
