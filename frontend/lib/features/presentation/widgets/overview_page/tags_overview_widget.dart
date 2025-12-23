import 'package:flutter/material.dart';
import 'package:frontend/features/data/models/tag.dart';

class TagsOverviewWidget extends StatelessWidget {
  final List<Tag> tags;
  final VoidCallback editTags;

  const TagsOverviewWidget({
    super.key,
    required this.tags,
    required this.editTags,
  });

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
          onPressed: editTags,
        ),
      ],
    ),
  );
}
