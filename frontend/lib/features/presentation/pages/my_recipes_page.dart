import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/pages/recipe_overview_page.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class MyRecipesPage extends ConsumerStatefulWidget {
  const MyRecipesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends ConsumerState<MyRecipesPage> {
  void updateUI() => ref.invalidate(recipesProvider);

  Future<void> _openRecipeOverview(int id, String title) async {
    try {
      final updated =
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeOverviewPage(recipeId: id, title: title),
            ),
          ) ??
          false;

      if (updated) {
        updateUI();
      }
    } catch (error) {
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Fehler"),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Schließen"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openRecipeOverview(id, title);
              },
              child: const Text("Wiederholen"),
            ),
          ],
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fehler beim Laden: $error")));
    }
  }

  void openEditView() async {
    try {
      final newRecipe = await Navigator.push<Recipe>(
        context,
        MaterialPageRoute(builder: (_) => RecipeEditPage()),
      );

      if (newRecipe == null) return;

      final id = await createNewRecipe(ref, newRecipe);

      updateUI();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Rezept gespeichert")));

      _openRecipeOverview(id, newRecipe.title);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Fehler beim Speichern")));
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<RecipeSimple>> recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meine Rezepte"),
        actions: [
          IconButton(
            onPressed: () => invalidateRepository(ref),
            icon: Icon(Icons.replay),
          ),
        ],
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
              onTap: () => _openRecipeOverview(recipe.id, recipe.title),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditView(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
