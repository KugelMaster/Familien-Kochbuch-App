// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nutrition _$NutritionFromJson(Map<String, dynamic> json) => Nutrition(
  name: json['name'] as String,
  amount: (json['amount'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$NutritionToJson(Nutrition instance) => <String, dynamic>{
  'name': instance.name,
  'amount': instance.amount,
  'unit': instance.unit,
};
