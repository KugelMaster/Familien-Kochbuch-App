import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';
import 'package:frontend/pages/recipe_overview_page.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  final List<Recipe> recipes = [
    Recipe(
      "Eierpfannenkuchen",
      ["Schnell", "Mittagessen", "Frühstück"],
      //"https://www.harecker.de/blog/wp-content/uploads/2018/04/Pfannenkuchen.jpg",
      null,
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