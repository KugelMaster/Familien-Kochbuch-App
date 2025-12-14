import 'package:flutter/material.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/presentation/recipe_overview_page.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  // final List<Recipe> recipes = [
  //   Recipe(
  //     title: "Eierpfannenkuchen",
  //     tags: ["Schnell", "Mittagessen", "Frühstück"],
  //     //"https://www.harecker.de/blog/wp-content/uploads/2018/04/Pfannenkuchen.jpg",
  //     image: null,
  //     description: "Eier und Mehl Kuchen",
  //     timePrep: 70,
  //     timeTotal: 90,
  //     portions: 12,
  //     recipeUri: "https://www.harecker.de/blog/grundrezept-fuer-pfannenkuchen/",
  //     ingredients: [
  //       Ingredient("Mehl", "125", "g"),
  //       Ingredient("Prise Salz", "1", null),
  //       Ingredient("Eier", "2", null),
  //       Ingredient("Milch", "300", "ml"),
  //     ],
  //     nutritions: [Nutrition("Zucker", "100", "g")],
  //     usernotes: [
  //       UserNote(
  //         1,
  //         "Nächstes mal doppelte Menge ;-)",
  //         DateTime.now(),
  //         DateTime.now(),
  //       ),
  //       UserNote(2, "Ohne Wasser", DateTime.now(), DateTime.now()),
  //     ],
  //     ratings: [Rating(1, 4.5, "Sehr lecker 😋", DateTime.now(), DateTime.now())],
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  // ];
  final List<Recipe> recipes = [];

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecipeOverviewPage(
                    recipe: recipe,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}