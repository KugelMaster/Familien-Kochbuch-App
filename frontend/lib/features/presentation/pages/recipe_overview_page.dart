import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/recipe_diff.dart';
import 'package:frontend/features/data/models/tag.dart';
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
import 'package:frontend/features/presentation/widgets/tag_edit_sheet.dart';
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
    ref
        .read(recipeRepositoryProvider.notifier)
        .updateRecipe(widget.recipeId, patch);
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

  Future<void> onEditTags() async {
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
    recipeAsync = ref.watch(recipeByIdProvider(widget.recipeId));

    final double triggerOffset = MediaQuery.of(context).size.height * 0.6;

    return recipeAsync.when(
      loading: () {
        print("Ich lade das Rezept...");
        return const CircularProgressIndicator();
      },
      error: (e, _) => Text("Fehler: $e"),
      data: (recipe) => Scaffold(
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

      if (recipe.tags != null)
        TagsOverviewWidget(tags: recipe.tags!, editTags: onEditTags),
      const SizedBox(height: 8),

      _title(recipe.title),
      if (recipe.description != null) _description(recipe.description!),
      const SizedBox(height: 6),

      if (recipe.ratings != null)
        RatingOverviewWidget(ratings: recipe.ratings!),
      const SizedBox(height: 12),

      InfoChipsOverviewWidget(
        recipe: recipe,
        iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(height: 24),

      if (recipe.recipeUri != null) _uriButton(recipe.recipeUri!),
      const SizedBox(height: 24),

      if (recipe.ingredients != null)
        IngredientsOverviewWidget(ingredients: recipe.ingredients!),
      const SizedBox(height: 24),

      if (recipe.nutritions != null)
        NutritionsOverviewWidget(nutritions: recipe.nutritions!),
      const SizedBox(height: 40),

      if (recipe.recipeNotes != null)
        RecipeNotesOverviewWidget(
          recipeId: widget.recipeId,
          recipeNotes: recipe.recipeNotes,
        ),
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
