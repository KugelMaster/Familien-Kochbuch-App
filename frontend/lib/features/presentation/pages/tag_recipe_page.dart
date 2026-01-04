import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/async_value_handler.dart';
import 'package:frontend/core/utils/format.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/presentation/pages/recipe_overview_page.dart';
import 'package:frontend/features/presentation/widgets/recipe_image.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class TagRecipePage extends ConsumerWidget {
  final Tag tag;

  const TagRecipePage({super.key, required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesByTagProvider(tag.id));

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(tag.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncValueHandler(
          asyncValue: recipesAsync,
          onData: (recipes) => _RecipeGrid(recipes: recipes),
        ),
      ),
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  final List<RecipeSimple> recipes;

  const _RecipeGrid({required this.recipes});

  @override
  Widget build(BuildContext context) => GridView.builder(
    itemCount: recipes.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75,
    ),
    itemBuilder: (context, index) => _RecipeCard(recipe: recipes[index]),
  );
}

class _RecipeCard extends StatelessWidget {
  final RecipeSimple recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  RecipeOverviewPage(recipeId: recipe.id, title: recipe.title),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: RecipeImage(imageId: recipe.imageId)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 4),
                      Text(Format.time(recipe.timeTotal)),
                      const Spacer(),
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
