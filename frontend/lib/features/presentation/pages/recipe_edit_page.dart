import 'package:flutter/material.dart';
import 'package:frontend/features/data/models/recipe.dart';

class RecipeEditPage extends StatefulWidget {
  final Recipe? recipe;

  const RecipeEditPage({super.key, this.recipe});

  @override
  State<StatefulWidget> createState() => _RecipeEditPage();
}

class _RecipeEditPage extends State<RecipeEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController timePrepCtrl;
  late TextEditingController timeTotalCtrl;
  late TextEditingController portionsCtrl;
  late TextEditingController linkCtrl;

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: widget.recipe?.title ?? "");
    descCtrl = TextEditingController(text: widget.recipe?.description ?? "");
    timePrepCtrl = TextEditingController(
      text: widget.recipe?.timePrep?.toString() ?? "",
    );
    timeTotalCtrl = TextEditingController(
      text: widget.recipe?.timeTotal?.toString() ?? "",
    );
    portionsCtrl = TextEditingController(
      text: widget.recipe?.portions?.toString() ?? "",
    );
    linkCtrl = TextEditingController(text: widget.recipe?.recipeUri ?? "");
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    timePrepCtrl.dispose();
    timeTotalCtrl.dispose();
    portionsCtrl.dispose();
    linkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe == null ? "Rezept erstellen" : "Rezept bearbeiten",
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _titleSection(),
            const SizedBox(height: 18),
            _infoSection(),
            const SizedBox(height: 18),
            _linkSection(),
            const SizedBox(height: 18),
            //_imageSection(),
            //_ingredientsSection(),
            //_nutritionSection(),
          ],
        ),
      ),
    );
  }

  Widget _titleSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: titleCtrl,
        decoration: const InputDecoration(labelText: "Titel"),
        validator: (v) => v == null || v.isEmpty ? "Titel fehlt" : null,
      ),
      const SizedBox(height: 18),
      TextFormField(
        controller: descCtrl,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          labelText: "Beschreibung",
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );

  Widget _infoSection() => Row(
    children: [
      Expanded(
        child: TextFormField(
          controller: timePrepCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Zubereitungszeit",
            suffixText: "min",
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: TextFormField(
          controller: timeTotalCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Gesamtzeit",
            suffixText: "min",
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: TextFormField(
          controller: portionsCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Portionen"),
        ),
      ),
    ],
  );

  Widget _linkSection() => Column(
    children: [
      TextFormField(
        controller: linkCtrl,
        decoration: const InputDecoration(labelText: "Link zum Rezept"),
        validator: (v) {
          if (v == null) return "Link nicht richtig eingegeben";
          final uri = Uri.tryParse(v);

          return uri == null || !uri.hasScheme
            ? "Link nicht richtig angegeben"
            : null;
        }
      ),
    ],
  );

  // Widget _tagsSection() => Column(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //     const Text("Tags"),
  //     Wrap(
  //       spacing: 8,
  //       children: tags.map((tag) {
  //         return Chip(
  //           label: Text(tag),
  //           onDeleted: () {
  //             setState(() => tags.remove(tag));
  //           },
  //         );
  //       }).toList(),
  //     ),
  //     TextButton.icon(
  //       onPressed: _addTag,
  //       icon: const Icon(Icons.add),
  //       label: const Text("Tag hinzufügen"),
  //     )
  //   ],
  // );

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final recipe = Recipe(
      title: titleCtrl.text,
      description: descCtrl.text,
      timePrep: int.tryParse(timePrepCtrl.text),
      timeTotal: int.tryParse(timeTotalCtrl.text),
      portions: double.tryParse(portionsCtrl.text),
      recipeUri: linkCtrl.text,
      ingredients: List.empty(),

      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, recipe);
  }
}
