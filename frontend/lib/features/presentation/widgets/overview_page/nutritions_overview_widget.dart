import 'package:flutter/material.dart';
import 'package:frontend/core/utils/format.dart';
import 'package:frontend/features/data/models/nutrition.dart';

class NutritionsOverviewWidget extends StatelessWidget {
  final List<Nutrition> nutritions;

  const NutritionsOverviewWidget({super.key, required this.nutritions});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          "Nährwerte",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 8),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: nutritions.map((nut) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "• ${Format.number(nut.amount)} ${nut.unit} ${nut.name}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}
