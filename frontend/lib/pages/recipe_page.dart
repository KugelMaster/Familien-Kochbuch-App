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
        Ingredient("Milch", "300", "ml")
      ],
      [
        Nutrition("name", "amount", "unit")
      ],
      [
        UserNote(1, "Nächstes mal doppelte Menge ;-)", DateTime.now(), DateTime.now())
      ],
      [
        Rating(1, 4.5, "Sehr lecker 😋", DateTime.now(), DateTime.now())
      ],
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
            if (recipe.image != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.network(
                  recipe.image!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            // ------------------------------------------
            // TITEL & BESCHREIBUNG
            // ------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (recipe.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  recipe.description!,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 12),

            // ------------------------------------------
            // INFOS ALS CHIPS (Zeit, Portionen)
            // ------------------------------------------
            Padding(
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
                      label: Text(
                        "Vorbereitung: ${recipe.timePrep!.toInt()} min",
                      ),
                      avatar: const Icon(Icons.kitchen),
                    ),
                  if (recipe.portions != null)
                    Chip(
                      label: Text("${recipe.portions!.toInt()} Portionen"),
                      avatar: const Icon(Icons.restaurant),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------
            // ZUTATEN
            // ------------------------------------------
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
                children: recipe.ingredients.map((ing) {
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

            const SizedBox(height: 24),

            // ------------------------------------------
            // OPTIONAL: URL ODER ZUBEREITUNGSSCHRITTE
            // ------------------------------------------
            if (recipe.recipeUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Originalrezept öffnen"),
                  onPressed: () {
                    // URL öffnen
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
