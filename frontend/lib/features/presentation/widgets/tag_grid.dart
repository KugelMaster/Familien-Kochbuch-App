import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/presentation/pages/tag_recipe_page.dart';
import 'package:frontend/features/providers/tag_providers.dart';

class TagGrid extends ConsumerWidget {
  const TagGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return tagsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text('Fehler: $e'),
        ),
      ),
      data: (tags) {
        return SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final tag = tags[index];
            return _TagCard(tag: tag);
          }, childCount: tags.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
        );
      },
    );
  }
}

class _TagCard extends StatelessWidget {
  final Tag tag;

  const _TagCard({required this.tag});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TagRecipePage(tag: tag)));
    },
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // TODO: Bild hier anzeigen falls implementiert
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
            ),
          ),
          Center(
            child: Text(
              tag.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
