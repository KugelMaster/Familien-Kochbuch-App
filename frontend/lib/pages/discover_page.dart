import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final List<String> suggestions = const [
    "Schweinelende mit Kroketten und Rahmsoße",
    "Bauerntopf",
    "Rigatoni al Forno",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchAnchor(
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final String query = controller.text;

                  return suggestions
                    .where((s) => s.toLowerCase().contains(query.toLowerCase()))
                    .map((s) => ListTile(
                      title: Text(s),
                      onTap:() {
                        setState(() {
                          controller.closeView(s);
                        });
                      },
                    ));
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Kategorien",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Expanded(child: CategoriesGrid()),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesGrid extends StatelessWidget {
  CategoriesGrid({super.key});

  final List<Map<String, String?>> categories = [
    {"name": "Frühstück", "image": "assets/images/fruehstueck.webp"},
    {"name": "Pasta", "image": null},
    {"name": "Salate", "image": null},
    {"name": "Desserts", "image": null},
    {"name": "Suppe", "image": null},
    {"name": "Vegetarisch", "image": null},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Kategorie Navigation hier
          },
          child: CategoryCard(
            title: cat["name"] ?? "",
            imagePath: cat["image"],
          ),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String? imagePath;

  const CategoryCard({super.key, required this.title, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage(imagePath!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.35),
                  BlendMode.darken,
                ),
              )
            : null,
        color: imagePath == null ? Colors.orange.shade200 : null,
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
