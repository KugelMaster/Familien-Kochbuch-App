import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/recipe_diff.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/presentation/widgets/tag_edit_sheet.dart';

class TagsOverviewWidget extends StatelessWidget {
  final List<Tag> tags;
  final void Function(RecipePatch) updateRecipe;

  const TagsOverviewWidget({
    super.key,
    required this.tags,
    required this.updateRecipe,
  });

  Future<void> editTags(BuildContext context) async {
    List<Tag>? updated = await showModalBottomSheet<List<Tag>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TagEditSheet(selected: tags),
    );

    if (updated == null) return;

    final idList = RecipeDiff.toIdList(updated);

    if (listEquals(RecipeDiff.toIdList(tags), idList)) {
      return;
    }

    updateRecipe(RecipePatch(tags: idList));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...tags.map(
          (tag) => Chip(label: Text(tag.name), backgroundColor: Colors.amber),
        ),
        ActionChip(
          label: const Text("Kategorie hinzufügen"),
          avatar: const Icon(Icons.add),
          onPressed: () => editTags(context),
        ),
      ],
    ),
  );
}
