import 'package:flutter/material.dart';
import 'package:frontend/features/data/models/rating.dart';

class RatingOverviewWidget extends StatelessWidget {
  final List<Rating> ratings;

  const RatingOverviewWidget({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    final avgStars = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: null,
        child: Row(
          children: [
            Row(
              children: List.generate(5, (i) {
                final filled = avgStars >= i + 1;
                final half = !filled && avgStars > i && avgStars < i + 1;

                return Icon(
                  filled
                      ? Icons.star
                      : half
                      ? Icons.star_half
                      : Icons.star_border,
                  size: 22,
                  color: Colors.orange,
                );
              }),
            ),
            const SizedBox(width: 6),
            Text(
              "(${ratings.length})",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
