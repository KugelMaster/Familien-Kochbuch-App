import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: const Center(
        child: Text(
          "Meine Rezepte",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}