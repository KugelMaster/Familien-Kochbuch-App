import 'package:flutter/material.dart';
import 'package:frontend/core/utils/format.dart';
import 'package:frontend/features/data/models/ingredient.dart';

class IngredientsOverviewWidget extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientsOverviewWidget({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          "Zutaten",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 8),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredients.map((ing) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "• ${Format.number(ing.amount)} ${ing.unit} ${ing.name}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}
