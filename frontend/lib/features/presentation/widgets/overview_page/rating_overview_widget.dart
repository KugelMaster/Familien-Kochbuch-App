import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/rating.dart';
import 'package:frontend/features/presentation/widgets/ratings_dialog.dart';
import 'package:frontend/features/providers/rating_providers.dart';

class RatingOverviewWidget extends ConsumerWidget {
  final int recipeId;

  const RatingOverviewWidget({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(ratingProvider(recipeId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ratingsAsync.when(
        loading: () => null,
        error: (e, _) => Text("Error: $e"),
        data: (ratings) => _buildStars(
          context: context,
          ratings: ratings,
          openRatingsDialog: () => showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => RatingsDialog(
              recipeId: recipeId,
              currentUserId: currentUserId,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStars({
    required BuildContext context,
    required List<Rating> ratings,
    required VoidCallback openRatingsDialog,
  }) {
    final avgStars = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;

    return InkWell(
      onTap: openRatingsDialog,
      child: Row(
        children: [
          Row(
            children: List.generate(5, (i) {
              final icon = avgStars >= i + 1
                  ? Icons.star
                  : avgStars > i && avgStars < i + 1
                  ? Icons.star_half
                  : Icons.star_border;

              return Icon(icon, size: 22, color: Colors.amber);
            }),
          ),
          const SizedBox(width: 6),
          Text(
            "(${ratings.length})",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
