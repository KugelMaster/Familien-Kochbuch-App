import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Recipe? selectedRecipe;

  final List<Recipe> recipes = [
    Recipe(
      "Eierpfannenkuchen",
      ["Schnell", "Mittagessen"],
      "https://www.harecker.de/blog/wp-content/uploads/2018/04/Pfannenkuchen.jpg",
      "Eier und Mehl Kuchen",
      15,
      20,
      12,
      "https://www.harecker.de/blog/grundrezept-fuer-pfannenkuchen/",
      [
        Ingredient("Mehl", "125", "g"),
        Ingredient("Prise Salz", "1", null),
        Ingredient("Eier", "2", null),
        Ingredient("Milch", "300", "ml"),
      ],
      [Nutrition("Zucker", "100", "g")],
      [
        UserNote(
          1,
          "Nächstes mal doppelte Menge ;-)",
          DateTime.now(),
          DateTime.now(),
        ),
        UserNote(2, "Ohne Wasser", DateTime.now(), DateTime.now()),
      ],
      [Rating(1, 4.5, "Sehr lecker 😋", DateTime.now(), DateTime.now())],
      DateTime.now(),
      DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (selectedRecipe == null) {
      return buildRecipeList();
    } else {
      return buildRecipeDetail(selectedRecipe!);
    }
  }

  Widget buildRecipeList() {
    return Scaffold(
      appBar: AppBar(title: const Text("Meine Rezepte")),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];

          return ListTile(
            title: Text(recipe.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              setState(() {
                selectedRecipe = recipe;
              });
            },
          );
        },
      ),
    );
  }

  Widget buildRecipeDetail(Recipe recipe) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() => selectedRecipe = null);
          },
        ),
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.tags != null) buildTags(recipe.tags!),

            if (recipe.ratings != null) buildRatingSummary(recipe.ratings!),

            if (recipe.image != null) buildImage(recipe.image!),

            const SizedBox(height: 16),

            ...buildTitleAndDescription(recipe.title, recipe.description),

            const SizedBox(height: 12),

            buildInfoChips(recipe),

            const SizedBox(height: 24),

            ...buildIngredients(recipe.ingredients),

            const SizedBox(height: 24),

            if (recipe.recipeUrl != null) buildUrlButton(recipe.recipeUrl!),

            const SizedBox(height: 24),

            ...buildNutritions(recipe.nutritions),

            const SizedBox(height: 40),

            if (recipe.usernotes != null)
              buildUserNotes(recipe.usernotes!),
          ],
        ),
      ),
    );
  }

  Widget buildTags(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: tags.map((tag) {
          return Chip(
            label: Text(tag),
            labelStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            side: BorderSide(color: Colors.black, width: 2),
          );
        }).toList(),
      ),
    );
  }

  Widget buildRatingSummary(List<Rating> ratings) {
    final avgStars = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;

    return InkWell(
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
    );
  }

  Widget buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
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
          "Inhaltsstoffe",
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
                    child: Icon(
                      Icons.person,
                    ), // TODO: Hier Profilbild anzeigen
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.text,
                          style: const TextStyle(fontSize: 16),
                        ),

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
