import 'package:flutter/material.dart';

class PlanerPage extends StatelessWidget {
  const PlanerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: const Center(
        child: Text(
          "Planer",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}