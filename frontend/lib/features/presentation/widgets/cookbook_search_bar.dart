import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/async_debouncer.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/pages/recipe_overview_page.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class CookbookSearchBar extends ConsumerStatefulWidget {
  const CookbookSearchBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CookbookSearchBarState();
}

class CookbookSearchBarState extends ConsumerState<CookbookSearchBar> {
  late final AsyncDebouncer<List<RecipeSimple>> _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = AsyncDebouncer(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<List<Widget>> _suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) async {
    final query = controller.text;

    try {
      final results = await _debouncer.run(
        () => ref.read(recipeServiceProvider).searchRecipes(query: query),
      );

      return results
          .map(
            (recipe) => ListTile(
              title: Text(recipe.title),
              onTap: () {
                controller.closeView(recipe.title);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeOverviewPage(
                      recipeId: recipe.id,
                      title: recipe.title,
                    ),
                  ),
                );
              },
            ),
          )
          .toList();
    } on Debounced {
      //FIXME: Wenn der benutzer den Debounced Fehler raised, dann werden alle bisher vorgeschlagenen Ergebnisse gelöscht. Irgendwie Methode abbrechen?
      return const [];
    } catch (e, st) {
      return [ListTile(title: Text("Fehler: $e \n$st"))];
    }
  }

  @override
  Widget build(BuildContext context) => SearchAnchor(
    builder: (context, controller) => SearchBar(
      controller: controller,
      hintText: "Rezepte suchen...",
      leading: const Icon(Icons.search),
      onTap: () => controller.openView(),
      onChanged: (value) {
        if (!controller.isOpen) {
          controller.openView();
        }
      },
    ),
    suggestionsBuilder: _suggestionsBuilder,
  );
}
