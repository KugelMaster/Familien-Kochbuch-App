import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/async_value_handler.dart';
import 'package:frontend/core/utils/undo_snack_bar.dart';
import 'package:frontend/features/data/models/rating.dart';
import 'package:frontend/features/presentation/widgets/delete_prompt.dart';
import 'package:frontend/features/providers/rating_providers.dart';

class RatingsDialog extends ConsumerStatefulWidget {
  final int recipeId;
  final int currentUserId;

  const RatingsDialog({
    super.key,
    required this.recipeId,
    required this.currentUserId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RatingsDialogState();
}

class _RatingsDialogState extends ConsumerState<RatingsDialog> {
  void _openCreateDialog() => showDialog(
    context: context,
    builder: (_) => RatingEditDialog(
      onSave: (stars, comment) {
        ref
            .read(ratingRepositoryProvider.notifier)
            .createRating(
              RatingCreate(
                userId: widget.currentUserId,
                recipeId: widget.recipeId,
                stars: stars,
                comment: comment,
              ),
            );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Bewertung erstellt")));
      },
    ),
  );

  void _openEditDialog(Rating rating) => showDialog(
    context: context,
    builder: (_) => RatingEditDialog(
      initialStars: rating.stars,
      initialComment: rating.comment,
      onSave: (stars, comment) {
        ref
            .read(ratingRepositoryProvider.notifier)
            .updateRating(
              RatingPatch(
                id: rating.id,
                recipeId: rating.recipeId,
                stars: stars,
                comment: comment,
              ),
            );

        UndoSnackBar(
          context: context,
          content: "Bewertung bearbeitet",
          onUndo: () => print("Bewertung Bearbeitung Rückgängig"),
        );
      },
    ),
  );

  Future<void> _confirmDelete(Rating rating) async {
    final confirmed = await DeletePrompt.open(
      context: context,
      title: "Bewertung löschen?",
      content: "Diese Aktion kann nicht rückgängig gemacht werden.",
    );

    if (!confirmed) return;

    await ref
        .read(ratingRepositoryProvider.notifier)
        .deleteRating(rating.recipeId, rating.id);

    if (!mounted) return;

    UndoSnackBar(
      context: context,
      content: "Bewertung gelöscht",
      onUndo: () => print("Bewertung Löschen Rückgängig"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratingsAsync = ref.watch(ratingProvider(widget.recipeId));

    return AsyncValueHandler(
      asyncValue: ratingsAsync,
      onData: (ratings) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Bewertungen",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                if (!ratings.any((r) => r.userId == widget.currentUserId))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _openCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text("Bewertung hinzufügen"),
                    ),
                  ),

                const SizedBox(height: 8),

                Expanded(
                  child: ratings.isEmpty
                      ? const Center(child: Text("Noch keine Bewertungen"))
                      : ListView.separated(
                          itemCount: ratings.length,
                          separatorBuilder: (_, _) => const Divider(height: 24),
                          itemBuilder: (context, index) =>
                              _ratingListTile(ratings[index]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingListTile(Rating rating) {
    bool isOwnRating = rating.userId == widget.currentUserId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          child: Text(
            // TODO: Profilbild hier
            rating.userId.toString(),
            style: const TextStyle(fontSize: 10),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < rating.stars.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 18,
                      color: Colors.amber,
                    );
                  }),

                  if (isOwnRating) ...[
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _openEditDialog(rating),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _confirmDelete(rating),
                    ),
                  ],
                ],
              ),

              if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(rating.comment!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class RatingEditDialog extends StatefulWidget {
  final double? initialStars;
  final String? initialComment;
  final void Function(double stars, String comment) onSave;

  const RatingEditDialog({
    super.key,
    this.initialStars,
    this.initialComment,
    required this.onSave,
  });

  @override
  State<StatefulWidget> createState() => _RatingEditDialogState();
}

class _RatingEditDialogState extends State<RatingEditDialog> {
  late double stars = widget.initialStars ?? 0;
  late TextEditingController commentController = TextEditingController(
    text: widget.initialComment,
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text("Bewertung"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() => stars = index + 1.0);
              },
            );
          }),
        ),

        TextField(
          controller: commentController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: "Kommentar (optional)"),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Abbrechen"),
      ),
      TextButton(
        onPressed: () {
          widget.onSave(stars, commentController.text.trim());
          Navigator.pop(context);
        },
        child: const Text("Speichern"),
      ),
    ],
  );
}
