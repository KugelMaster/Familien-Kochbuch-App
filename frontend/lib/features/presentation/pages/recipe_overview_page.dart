import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/recipe_diff.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/widgets/animated_app_bar.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/widgets/recipe_overview_widgets.dart';
import 'package:frontend/features/providers/recipe_providers.dart';
import 'package:image_picker/image_picker.dart';

class RecipeOverviewPage extends ConsumerStatefulWidget {
  final int recipeId;

  const RecipeOverviewPage({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<RecipeOverviewPage> createState() => _RecipeOverviewPageState();
}

class _RecipeOverviewPageState extends ConsumerState<RecipeOverviewPage> {
  final ScrollController _scrollController = ScrollController();

  late AsyncValue<Recipe> recipeAsync;

  @override
  Widget build(BuildContext context) {
    recipeAsync = ref.watch(recipeProvider(widget.recipeId));

    final double triggerOffset = MediaQuery.of(context).size.height * 0.6;

    return recipeAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Fehler: $e"),
      data: (recipe) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AnimatedAppBar(
          scrollController: _scrollController,
          title: recipe.title,
          triggerOffset: triggerOffset,
        ),
        body: SingleChildScrollView(
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
                RecipeOverviewWidgets.buildTags(recipe.tags!),
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
        floatingActionButton: FloatingActionButton(
          onPressed: openEditView,
          child: const Icon(Icons.edit),
        ),
      )
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

    final service = ref.read(recipeServiceProvider);
    return await service.getImage(recipe.imageId!);
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      final service = ref.read(recipeServiceProvider);
      final imageId = await service.sendImage(image);

      Recipe updatedRecipe = await service.updateRecipe(
        widget.recipeId,
        RecipePatch(imageId: imageId),
      );

      updatedRecipe.image = image;

      ref.read(recipeProvider(widget.recipeId).notifier).updateLocal(updatedRecipe);
    }
  }

  void openEditView() async {
    if (recipeAsync.value == null) {
      throw Exception("How is this possible? You should not open a recipe overview page with no recipe to show and then try to edit it!");
    }

    Recipe oldRecipe = recipeAsync.value!;

    // Open the Edit UI for the User and wait for a result
    final updatedRecipe = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (_) => RecipeEditPage(recipe: oldRecipe)),
    );

    // If the user cancelled, then end the function
    if (updatedRecipe == null) return;

    // First, retrieve all differences in comparison to the old recipe:
    RecipePatch patch = RecipeDiff.from(oldRecipe, updatedRecipe);

    // If a new image was created, upload it to the backend and store the new imageId.
    final service = ref.read(recipeServiceProvider);
    if (updatedRecipe.imageId == null && updatedRecipe.image != null) {
      patch.imageId = await service.sendImage(updatedRecipe.image!);
    }

    // If nothing changed, exit
    if (patch.isEmpty) return;

    // Lastly, send the whole patch (with optional new imageId) to the backend and get the new Recipe-Object
    final newRecipe = await service.updateRecipe(widget.recipeId, patch);

    // ... and update the UI
    ref.read(recipeProvider(widget.recipeId).notifier).updateLocal(newRecipe);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rezept aktualisiert")));
  }
}
