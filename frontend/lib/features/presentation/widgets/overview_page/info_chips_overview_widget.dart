import 'package:flutter/material.dart';
import 'package:frontend/core/utils/format.dart';
import 'package:frontend/features/data/models/recipe.dart';

class InfoChipsOverviewWidget extends StatelessWidget {
  final Recipe recipe;
  final Color iconColor;

  const InfoChipsOverviewWidget({
    super.key,
    required this.recipe,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Icon(Icons.timer, color: iconColor),
        const SizedBox(width: 6),
        Text(Format.time(recipe.timePrep)),

        const SizedBox(width: 12),
        Container(width: 1, height: 16, color: Colors.grey.shade500),
        const SizedBox(width: 12),

        Icon(Icons.schedule, color: iconColor),
        const SizedBox(width: 6),
        Text(Format.time(recipe.timeTotal)),

        const SizedBox(width: 12),
        Container(width: 1, height: 16, color: Colors.grey.shade500),
        const SizedBox(width: 12),

        Icon(Icons.fastfood, color: iconColor),
        const SizedBox(width: 6),
        Text("${Format.number(recipe.portions)} Stück"),
      ],
    ),
  );
}
