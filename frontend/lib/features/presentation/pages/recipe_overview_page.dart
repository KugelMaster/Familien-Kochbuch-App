import 'package:flutter/material.dart';
import 'package:frontend/features/presentation/pages/recipe_edit_page.dart';
import 'package:frontend/features/presentation/widgets/animated_app_bar.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/widgets/recipe_overview_widgets.dart';
import 'package:image_picker/image_picker.dart';

class RecipeOverviewPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeOverviewPage({super.key, required this.recipe});

  @override
  State<RecipeOverviewPage> createState() => _RecipeOverviewPageState();
}

class _RecipeOverviewPageState extends State<RecipeOverviewPage> {
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
              imageUrl: recipe.image,
              pickedImage: pickedImage,
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

            ...RecipeOverviewWidgets.buildIngredients(recipe.ingredients),
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

  Future<void> takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        pickedImage = image;
      });

      // TODO: Image an Backend senden
    }
  }

  void openEditView() async {
    final updatedRecipe = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (_) => RecipeEditPage(recipe: widget.recipe)),
    );

    if (updatedRecipe != null) {
      // TODO: Update UI + Send to Backend
      Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeOverviewPage(recipe: updatedRecipe)));
    }
  }
}
