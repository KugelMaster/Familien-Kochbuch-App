import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/async_value_handler.dart';
import 'package:frontend/core/utils/recipe_diff.dart';
import 'package:frontend/core/utils/undo_snack_bar.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/widgets/animated_app_bar.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/widgets/overview_page/image_overview_widget.dart';
import 'package:frontend/features/presentation/widgets/overview_page/info_chips_overview_widget.dart';
import 'package:frontend/features/presentation/widgets/overview_page/ingredients_overview_widget.dart';
import 'package:frontend/features/presentation/widgets/overview_page/nutritions_overview_widget.dart';
import 'package:frontend/features/presentation/widgets/overview_page/rating_overview_widget.dart';
import 'package:frontend/features/presentation/widgets/overview_page/recipe_notes_overview_widget.dart';
import 'package:frontend/features/presentation/widgets/overview_page/tags_overview_widget.dart';
import 'package:frontend/features/providers/recipe_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool recipeWasUpdated = false;

  void onClose(bool deleted) {
    if (deleted) {
      Navigator.pop(context, true);

      UndoSnackBar(
        context: context,
        content: "Rezept gelöscht",
        onUndo: () => print("[RecipeOverviewPage] Löschen Rückgängig"),
      );

      return;
    }

    Navigator.pop(context, recipeWasUpdated);
  }

  void updateRecipe(RecipePatch patch) {
    ref
        .read(recipeRepositoryProvider.notifier)
        .updateRecipe(widget.recipeId, patch);
    recipeWasUpdated = true;

    UndoSnackBar(
      context: context,
      content: "Rezept bearbeitet",
      onUndo: () => print("[RecipeOverviewPage] Bearbeitung Rückgängig"),
    );
  }

  Future<void> onTakePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      updateRecipe(RecipePatch(image: image));
    }
  }

  Future<void> openEditView(Recipe oldRecipe) async {
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

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeProvider(widget.recipeId));
    final double triggerOffset = MediaQuery.of(context).size.height * 0.6;

    return AsyncValueHandler(
      asyncValue: recipeAsync,
      onData: (recipe) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AnimatedAppBar(
          scrollController: _scrollController,
          recipeId: widget.recipeId,
          title: recipeAsync.value?.title ?? widget.title ?? "<Name unbekannt>",
          triggerOffset: triggerOffset,
          onClose: onClose,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: _buildOverview(recipe),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openEditView(recipe),
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget _buildOverview(Recipe recipe) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ImageOverviewWidget(
        recipeId: widget.recipeId,
        takePhoto: onTakePhoto,
        screenHeight: MediaQuery.of(context).size.height,
      ),
      const SizedBox(height: 8),

      if (recipe.tags.isNotEmpty)
        TagsOverviewWidget(tags: recipe.tags, updateRecipe: updateRecipe),
      const SizedBox(height: 8),

      _title(recipe.title),
      if (recipe.description != null) _description(recipe.description!),
      const SizedBox(height: 6),

      RatingOverviewWidget(recipeId: widget.recipeId),
      const SizedBox(height: 12),

      InfoChipsOverviewWidget(
        recipe: recipe,
        iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(height: 24),

      if (recipe.recipeUri != null) _uriButton(recipe.recipeUri!),
      const SizedBox(height: 24),

      IngredientsOverviewWidget(ingredients: recipe.ingredients),
      const SizedBox(height: 24),

      NutritionsOverviewWidget(nutritions: recipe.nutritions),
      const SizedBox(height: 40),

      RecipeNotesOverviewWidget(recipeId: widget.recipeId),
      const SizedBox(height: 320),
    ],
  );

  Widget _title(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      title,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  );

  Widget _description(String description) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      description,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );

  Widget _uriButton(String uri) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: OutlinedButton.icon(
      icon: const Icon(Icons.open_in_new),
      label: const Text("Originalrezept öffnen"),
      onPressed: () async {
        if (!await launchUrl(
          Uri.parse(uri),
          mode: LaunchMode.externalApplication,
        )) {
          throw Exception("Could not launch $uri");
        }
      },
    ),
  );
}
