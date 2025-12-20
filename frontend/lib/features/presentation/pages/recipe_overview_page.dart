import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/recipe_diff.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/widgets/animated_app_bar.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/widgets/recipe_overview_widgets.dart';
import 'package:frontend/features/presentation/widgets/tag_edit_sheet.dart';
import 'package:frontend/features/providers/recipe_providers.dart';
import 'package:image_picker/image_picker.dart';

/// Shows a detailed user interface of a recipe.
///
/// Needs a [recipeId] to fetch the recipe from the recipe provider.
///
/// Returns a [bool] on close (via Navigator.pop):
/// * [true] - Indicates a change of the internal recipe data (e.g. deleted, title edited, ...).
/// * [false] or [null] - The page closed normally without any updates.
class RecipeOverviewPage extends ConsumerStatefulWidget {
  final int recipeId;
  final String? title;

  const RecipeOverviewPage({super.key, required this.recipeId, this.title});

  @override
  ConsumerState<RecipeOverviewPage> createState() => _RecipeOverviewPageState();
}

class _RecipeOverviewPageState extends ConsumerState<RecipeOverviewPage> {
  final ScrollController _scrollController = ScrollController();

  late AsyncValue<Recipe> recipeAsync;
  bool recipeWasUpdated = false;

  void onClose(bool deleted) {
    if (deleted) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rezept gelöscht"),
          action: SnackBarAction(
            label: "Rückgängig",
            onPressed: () {
              // TODO: Löschen rückgängig machen
              print("[Löschen] Rückgängig Knopf wurde gedrückt!");
            },
          ),
        ),
      );

      return;
    }

    Navigator.pop(context, recipeWasUpdated);
  }

  void updateRecipe(RecipePatch patch) {
    ref.read(recipeProvider(widget.recipeId).notifier).updateRecipe(patch);
    recipeWasUpdated = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rezept aktualisiert"),
        action: SnackBarAction(
          label: "Rückgängig",
          onPressed: () {
            // TODO: Bearbeitung rückgängig machen
            print("[Bearbeitung] Rückgängig Knopf wurde gedrückt!");
          },
        ),
      ),
    );
  }

  void editTags() async {
    List<Tag>? updated = await showModalBottomSheet<List<Tag>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TagEditSheet(selected: recipeAsync.value?.tags),
    );

    if (updated == null) return;

    final idList = RecipeDiff.toIdList(updated);

    if (listEquals(RecipeDiff.toIdList(recipeAsync.value?.tags), idList)) {
      return;
    }

    updateRecipe(RecipePatch(tags: idList));
  }

  @override
  Widget build(BuildContext context) {
    recipeAsync = ref.watch(recipeProvider(widget.recipeId));

    final double triggerOffset = MediaQuery.of(context).size.height * 0.6;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AnimatedAppBar(
        scrollController: _scrollController,
        recipeId: widget.recipeId,
        title: recipeAsync.value?.title ?? widget.title ?? "<Name unbekannt>",
        triggerOffset: triggerOffset,
        onClose: onClose,
      ),
      body: recipeAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text("Fehler: $e"),
        data: (recipe) => SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipeOverviewWidgets.buildImage(
                getPhoto: takePhoto,
                screenHeight: MediaQuery.of(context).size.height,
                getImage: getImage,
              ),
              const SizedBox(height: 8),

              if (recipe.tags != null)
                RecipeOverviewWidgets.buildTags(recipe.tags!, editTags),
              const SizedBox(height: 8),

              RecipeOverviewWidgets.buildTitle(recipe.title),
              if (recipe.description != null)
                RecipeOverviewWidgets.buildDescription(recipe.description!),
              const SizedBox(height: 6),

              if (recipe.ratings != null)
                RecipeOverviewWidgets.buildRatingSummary(recipe.ratings!),
              const SizedBox(height: 12),

              RecipeOverviewWidgets.buildInfoChips(
                recipe,
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),

              if (recipe.recipeUri != null)
                RecipeOverviewWidgets.buildUriButton(recipe.recipeUri!),
              const SizedBox(height: 24),

              if (recipe.ingredients != null)
                ...RecipeOverviewWidgets.buildIngredients(recipe.ingredients!),
              const SizedBox(height: 24),

              ...RecipeOverviewWidgets.buildNutritions(recipe.nutritions),
              const SizedBox(height: 40),

              if (recipe.usernotes != null)
                RecipeOverviewWidgets.buildUserNotes(recipe.usernotes!),
              const SizedBox(height: 320),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openEditView,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future<XFile?> getImage() async {
    if (recipeAsync.value == null) return null;

    Recipe recipe = recipeAsync.value!;

    if (recipe.image != null) {
      return recipe.image;
    }

    if (recipe.imageId == null) {
      return null;
    }

    return await ref.read(imageServiceProvider).getImage(recipe.imageId!);
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      updateRecipe(RecipePatch(image: image));
    }
  }

  void openEditView() async {
    if (recipeAsync.value == null) {
      throw Exception(
        "How is this possible? You should not open a recipe overview page with no recipe to show and then try to edit it!",
      );
    }

    Recipe oldRecipe = recipeAsync.value!;
    final updatedRecipe = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecipeEditPage(recipeId: widget.recipeId, recipe: oldRecipe),
      ),
    );

    if (updatedRecipe == null) return;

    RecipePatch patch = RecipeDiff.from(oldRecipe, updatedRecipe);
    if (patch.isEmpty) return;

    updateRecipe(patch);
  }
}
