import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/presentation/pages/recipe_overview_page.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class MyRecipesPage extends ConsumerWidget {
  const MyRecipesPage({super.key});

  Future<void> _openRecipeOverview(
    BuildContext context,
    WidgetRef ref,
    int id
  ) async {
    final service = ref.read(recipeServiceProvider);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Lade...'),
            ],
          ),
        ),
      ),
    );

    try {
      final fetched = await service.getById(id);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeOverviewPage(
            recipeId: id,
            recipe: fetched,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fehler'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Schließen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _openRecipeOverview(context, ref, id);
              },
              child: const Text('Wiederholen'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Meine Rezepte")),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Fehler: $error")),
        data: (recipes) => ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];

            return ListTile(
              title: Text(recipe.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openRecipeOverview(context, ref, recipe.id),
            );
          },
        ),
      ),
    );
  }
}
