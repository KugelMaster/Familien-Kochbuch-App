import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/pages/recipe_overview_page.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class MyRecipesPage extends ConsumerWidget {
  const MyRecipesPage({super.key});

  Future<void> _openRecipeOverview(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeOverviewPage(recipeId: id),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      //Navigator.of(context).pop(); // close loading dialog

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Laden: $error')));
    }
  }

  void openEditView(BuildContext context, WidgetRef ref, void Function() reloadView) async {
    // Get the new recipe filled with data entered by the user
    final newRecipe = await Navigator.push<Recipe?>(
      context,
      MaterialPageRoute(builder: (_) => RecipeEditPage()),
    );

    // If the user cancelled, the function stops
    if (newRecipe == null) return;

    // Otherwise, the recipe is going to be send to the backend api.
    try {
      final service = ref.read(recipeServiceProvider);
      if (newRecipe.image != null) {
        newRecipe.imageId = await service.sendImage(newRecipe.image!);
      }

      final (id, recipe) = await service.createRecipe(newRecipe);
      // TODO: Cache the recipe with the id so that the overview page doesn't have to ask the API again
      // Cache here: recipeProvider(id)

      // Afterwards, reload the view
      reloadView();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rezept gespeichert")));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeOverviewPage(recipeId: id),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fehler beim Speichern")));
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<RecipeSimple>> recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meine Rezepte"),
        actions: [IconButton(onPressed: () => ref.invalidate(recipesProvider), icon: Icon(Icons.replay))],
      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditView(context, ref, () => ref.invalidate(recipesProvider)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
