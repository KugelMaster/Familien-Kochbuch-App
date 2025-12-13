import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';
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
            buildImage(recipe.image),

            const SizedBox(height: 8),

            if (recipe.tags != null) buildTags(recipe.tags!),

            const SizedBox(height: 8),

            ...buildTitleAndDescription(recipe.title, recipe.description),

            const SizedBox(height: 6),

            if (recipe.ratings != null) buildRatingSummary(recipe.ratings!),

            const SizedBox(height: 12),

            buildInfoChips(recipe),

            const SizedBox(height: 24),

            ...buildIngredients(recipe.ingredients),

            const SizedBox(height: 24),

            if (recipe.recipeUrl != null) buildUrlButton(recipe.recipeUrl!),

            const SizedBox(height: 24),

            ...buildNutritions(recipe.nutritions),

            const SizedBox(height: 40),

            if (recipe.usernotes != null) buildUserNotes(recipe.usernotes!),

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

  void openEditView() {
    print("FAB was clicked!");
  }

  Widget buildTags(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: tags.map((tag) {
          return Chip(label: Text(tag), backgroundColor: Colors.amber);
        }).toList(),
      ),
    );
  }

  Widget buildRatingSummary(List<Rating> ratings) {
    final avgStars = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: null,
        child: Row(
          children: [
            Row(
              children: List.generate(5, (i) {
                final filled = avgStars >= i + 1;
                final half = !filled && avgStars > i && avgStars < i + 1;

                return Icon(
                  filled
                      ? Icons.star
                      : half
                      ? Icons.star_half
                      : Icons.star_border,
                  size: 22,
                  color: Colors.orange,
                );
              }),
            ),
            const SizedBox(width: 6),
            Text(
              "(${ratings.length})",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage(String? imageUrl) {
    final height = MediaQuery.of(context).size.height * 0.6;
    final Widget imageOrFiller;

    // PRIORITY:
    // 1. Pick image taken from user
    if (pickedImage != null) {
      imageOrFiller = Image.file(File(pickedImage!.path), fit: BoxFit.cover);
    }
    // 2. Display image from the url
    else if (imageUrl != null) {
      imageOrFiller = Image.network(imageUrl, fit: BoxFit.cover);
    }
    // 3. Display a filler
    else {
      imageOrFiller = InkWell(
        onTap: takePhoto,
        child: Container(
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "Foto hinzufügen",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: imageOrFiller,
          ),
          Positioned(
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildTitleAndDescription(String title, String? description) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),

      if (description != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
    ];
  }

  Widget buildInfoChips(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (recipe.timeTotal != null)
            Chip(
              label: Text("Gesamt: ${recipe.timeTotal!.toInt()} min"),
              avatar: const Icon(Icons.timer),
            ),
          if (recipe.timePrep != null)
            Chip(
              label: Text("Vorbereitung: ${recipe.timePrep!.toInt()} min"),
              avatar: const Icon(Icons.kitchen),
            ),
          if (recipe.portions != null)
            Chip(
              label: Text("${recipe.portions!.toInt()} Portionen"),
              avatar: const Icon(Icons.restaurant),
            ),
        ],
      ),
    );
  }

  List<Widget> buildIngredients(List<Ingredient> ingredients) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          "Zutaten",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 8),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredients.map((ing) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "• ${ing.amount} ${ing.unit} ${ing.name}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  Widget buildUrlButton(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text("Originalrezept öffnen"),
        onPressed: () {
          // TODO: URL öffnen
        },
      ),
    );
  }

  List<Widget> buildNutritions(List<Nutrition>? nutritions) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          "Nährwerte",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 8),

      if (nutritions != null && nutritions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: nutritions.map((nut) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "• ${nut.amount} ${nut.unit} ${nut.name}",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        )
      else
        Text(
          "<noch nicht eingetragen>",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
    ];
  }

  Widget buildUserNotes(List<UserNote> usernotes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: usernotes.map((note) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person), // TODO: Hier Profilbild anzeigen
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.text, style: const TextStyle(fontSize: 16)),

                        const SizedBox(height: 6),

                        Text(
                          _formatNoteDate(note),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatNoteDate(UserNote n) {
    final created =
        "${n.createdAt.day}.${n.createdAt.month}.${n.createdAt.year}";
    final updated = n.updatedAt != n.createdAt ? " (bearbeitet)" : "";
    return "Erstellt am $created$updated";
  }
}

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final String title;
  final double triggerOffset;

  const AnimatedAppBar({
    super.key,
    required this.scrollController,
    required this.title,
    required this.triggerOffset,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  bool scrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldBeScrolled =
        widget.scrollController.offset > widget.triggerOffset;

    if (shouldBeScrolled != scrolled) {
      setState(() => scrolled = shouldBeScrolled);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: scrolled ? Colors.white : Colors.transparent,
        border: scrolled
            ? const Border(
                bottom: BorderSide(color: Colors.black12, width: 0.8),
              )
            : null,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: scrolled ? Colors.black : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedOpacity(
          opacity: scrolled ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
