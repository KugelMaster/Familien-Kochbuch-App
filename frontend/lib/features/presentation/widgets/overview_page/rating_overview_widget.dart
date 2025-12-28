import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/core/utils/async_value_handler.dart';
import 'package:frontend/features/presentation/widgets/ratings_dialog.dart';
import 'package:frontend/features/providers/rating_providers.dart';

class RatingOverviewWidget extends ConsumerWidget {
  final int recipeId;

  const RatingOverviewWidget({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avgStarsAsync = ref.watch(ratingAvgStarsProvider(recipeId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AsyncValueHandler(
        asyncValue: avgStarsAsync,
        onData: (data) {
          final (avgStars, totalRatings) = data;

          return InkWell(
            onTap: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => RatingsDialog(
                recipeId: recipeId,
                currentUserId: currentUserId,
              ),
            ),
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
                  "($totalRatings)",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
