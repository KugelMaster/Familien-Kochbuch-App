import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/widgets/animated_app_bar.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/widgets/recipe_overview_widgets.dart';
import 'package:frontend/features/providers/recipe_providers.dart';
import 'package:image_picker/image_picker.dart';

class RecipeOverviewPage extends ConsumerStatefulWidget {
  final int recipeId;
  final Recipe recipe;

  const RecipeOverviewPage({
    super.key,
    required this.recipeId,
    required this.recipe,
  });

  @override
  ConsumerState<RecipeOverviewPage> createState() => _RecipeOverviewPageState();
}

class _RecipeOverviewPageState extends ConsumerState<RecipeOverviewPage> {
  final ScrollController _scrollController = ScrollController();

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  @override
  Widget build(BuildContext context) {
    final double triggerOffset = MediaQuery.of(context).size.height * 0.6;
    Recipe recipe = widget.recipe;

    return Scaffold(
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
    );
  }

  Future<XFile?> getImage() async {
    if (pickedImage != null) {
      return pickedImage!;
    }

    if (widget.recipe.imageId == null) {
      print("ImageId is null!");
      return null;
    }

    final service = ref.read(recipeServiceProvider);
    return await service.getImage(widget.recipe.imageId!);
  }

  Future<void> takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        pickedImage = image;
      });

      final service = ref.read(recipeServiceProvider);
      widget.recipe.imageId = await service.sendImage(image);
      Recipe newRecipe = await service.updateRecipe(
        widget.recipeId,
        RecipeUpdate(imageId: widget.recipe.imageId),
      );

      print(newRecipe);
    }
  }

  void openEditView() async {
    final updatedRecipe = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (_) => RecipeEditPage(recipe: widget.recipe)),
    );

    if (updatedRecipe != null) {
      // TODO: Update UI + Send to Backend
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeOverviewPage(recipeId: widget.recipeId, recipe: updatedRecipe),
        ),
      );
    }
  }
}
