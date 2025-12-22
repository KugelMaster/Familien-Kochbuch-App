import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/format.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/features/data/models/ingredient.dart';
import 'package:frontend/features/data/models/nutrition.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/providers/recipe_providers.dart';
import 'package:image_picker/image_picker.dart';

class RecipeEditPage extends ConsumerStatefulWidget {
  final int? recipeId;
  final Recipe? recipe;

  const RecipeEditPage({super.key, this.recipeId, this.recipe});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RecipeEditPage();
}

class _RecipeEditPage extends ConsumerState<RecipeEditPage> {
  final _formKey = GlobalKey<FormState>();

  final picker = ImagePicker();
  XFile? image;
  int? imageId;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final timePrepCtrl = TextEditingController();
  final timeTotalCtrl = TextEditingController();
  final portionsCtrl = TextEditingController();
  final linkCtrl = TextEditingController();

  final List<IngredientOrNutritionDraft> ingredients = [];
  final List<IngredientOrNutritionDraft> nutritions = [];

  final metadataLabelStyle = TextStyle(
    color: Colors.grey.shade600,
    fontSize: 12,
  );

  @override
  void initState() {
    super.initState();

    if (widget.recipe == null) return;
    Recipe recipe = widget.recipe!;

    titleCtrl.text = recipe.title;
    descCtrl.text = recipe.description ?? "";
    timePrepCtrl.text = Format.number(
      recipe.timePrep?.toDouble(),
      defaultReturn: "",
    );
    timeTotalCtrl.text = Format.number(
      recipe.timeTotal?.toDouble(),
      defaultReturn: "",
    );
    portionsCtrl.text = Format.number(recipe.portions, defaultReturn: "");
    linkCtrl.text = recipe.recipeUri ?? "";

    recipe.ingredients?.forEach(
      (ing) => ingredients.add(
        IngredientOrNutritionDraft(
          name: ing.name,
          amount: ing.amount,
          unit: ing.unit,
        ),
      ),
    );
    recipe.nutritions?.forEach(
      (nut) => nutritions.add(
        IngredientOrNutritionDraft(
          name: nut.name,
          amount: nut.amount,
          unit: nut.unit,
        ),
      ),
    );

    loadImage(recipe);
  }

  Future<void> loadImage(Recipe recipe) async {
    setState(() => imageId = recipe.imageId);

    if (recipe.image != null) setState(() => this.image = recipe.image);

    if (recipe.imageId == null) return;

    final image = await ref
        .read(imageServiceProvider)
        .getImage(recipe.imageId!);
    setState(() => this.image = image);
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _imageSection(),
            const SizedBox(height: 24),
            _titleSection(),
            const SizedBox(height: 16),
            _descriptionSection(),
            const SizedBox(height: 24),
            _timeSection(),
            const SizedBox(height: 16),
            _portionsSection(),
            const SizedBox(height: 16),
            _linkSection(),
            const SizedBox(height: 24),
            _ingredientsSection(),
            const SizedBox(height: 24),
            _nutritionsSection(),
            const SizedBox(height: 240),
            _metadataSection(),
          ],
        ),
      ),
    );
  }

  Widget _imageSection() => GestureDetector(
    onTap: _pickImage,
    child: Hero(
      tag: "recipe-image",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: image == null
                  ? Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.camera_alt, size: 40),
                    )
                  : Image.file(File(image!.path), fit: BoxFit.cover),
            ),
          ),
          if (imageId != null) Text("ID: $imageId"),
        ],
      ),
    ),
  );

  Widget _titleSection() => TextFormField(
    controller: titleCtrl,
    maxLines: 1,
    textInputAction: TextInputAction.next,
    decoration: const InputDecoration(labelText: "Titel"),
    validator: (value) => value == null || value.trim().isEmpty
        ? "Titel darf nicht leer sein"
        : null,
  );

  Widget _descriptionSection() => TextFormField(
    controller: descCtrl,
    maxLines: 5,
    keyboardType: TextInputType.multiline,
    decoration: const InputDecoration(
      labelText: "Beschreibung",
      alignLabelWithHint: true,
      //border: OutlineInputBorder(),
    ),
  );

  Widget _timeSection() => Row(
    children: [
      Expanded(
        child: _intField(controller: timePrepCtrl, label: "Zubereitungszeit"),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _intField(controller: timeTotalCtrl, label: "Gesamtzeit"),
      ),
    ],
  );

  Widget _intField({
    required TextEditingController controller,
    required String label,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    textInputAction: TextInputAction.next,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(labelText: label, suffixText: "min"),
    validator: (value) {
      if (value == null || value.isEmpty) return null;

      final number = int.tryParse(value);
      return number == null || number < 0 ? "Ungültige Zahl" : null;
    },
  );

  Widget _portionsSection() => TextFormField(
    controller: portionsCtrl,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: "Portionen"),
    validator: (value) {
      if (value == null || value.isEmpty) return null;

      final parsed = Format.parseString(value);
      if (parsed == null || parsed < 0) {
        return "Ungültige Portionsanzahl";
      }

      // max. eine Nachkommastelle
      final parts = value.split(RegExp(r"[.,]"));
      if (parts.length == 2 && parts[1].length > 1) {
        return "Maximal eine Nachkommastelle erlaubt";
      }

      return null;
    },
  );

  Widget _linkSection() => TextFormField(
    controller: linkCtrl,
    keyboardType: TextInputType.url,
    decoration: InputDecoration(
      labelText: "Rezept-Link",
      hintText: "https:// oder http://",
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return null;

      final uri = Uri.tryParse(value.trim());
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return "Ungültige URL";
      }

      return null;
    },
  );

  Widget _ingredientsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Zutaten",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      ...ingredients.map(_ingredientRow),

      TextButton.icon(
        onPressed: () {
          setState(() => ingredients.add(IngredientOrNutritionDraft()));
        },
        icon: const Icon(Icons.add),
        label: const Text("Zutat hinzufügen"),
      ),
    ],
  );

  Widget _ingredientRow(IngredientOrNutritionDraft ing) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: ing.name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Zutat"),
            validator: (value) =>
                value == null || value.isEmpty ? "Zutat ist leer" : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: ing.amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Menge"),
            validator: (value) {
              if (value == null) return null;

              return Format.parseString(value) == null ? "Zahl!" : null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String?>(
            initialValue: ing.unit,
            items: const [
              DropdownMenuItem(value: null, child: Text("<leer>")),
              DropdownMenuItem(value: "g", child: Text("g")),
              DropdownMenuItem(value: "ml", child: Text("ml")),
              DropdownMenuItem(value: "Stk", child: Text("Stk")),
              DropdownMenuItem(value: "EL", child: Text("EL")),
              DropdownMenuItem(value: "TL", child: Text("TL")),
              DropdownMenuItem(value: "Prise", child: Text("Prise")),
            ],
            onChanged: (v) => ing.unit = v,
            decoration: const InputDecoration(labelText: "Einheit"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() => ingredients.remove(ing));
          },
        ),
      ],
    ),
  );

  Widget _nutritionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Nährstoffe",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      ...nutritions.map(_nutritionRow),

      TextButton.icon(
        onPressed: () {
          setState(() => nutritions.add(IngredientOrNutritionDraft()));
        },
        icon: const Icon(Icons.add),
        label: const Text("Nährstoff hinzufügen"),
      ),
    ],
  );

  Widget _nutritionRow(IngredientOrNutritionDraft nut) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: nut.name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Nährstoff"),
            validator: (value) =>
                value == null || value.isEmpty ? "Nährstoff ist leer" : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: nut.amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Menge"),
            validator: (value) {
              if (value == null) return null;

              return Format.parseString(value) == null ? "Zahl!" : null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String?>(
            initialValue: nut.unit,
            items: const [
              DropdownMenuItem(value: null, child: Text("<leer>")),
              DropdownMenuItem(value: "g", child: Text("g")),
              DropdownMenuItem(value: "mg", child: Text("mg")),
              DropdownMenuItem(value: "ml", child: Text("ml")),
              DropdownMenuItem(value: "kcal", child: Text("kcal")),
            ],
            onChanged: (v) => nut.unit = v,
            decoration: const InputDecoration(labelText: "Einheit"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() => nutritions.remove(nut));
          },
        ),
      ],
    ),
  );

  Widget _metadataSection() => Padding(
    padding: EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.recipeId != null)
          Text("Rezept ID: ${widget.recipeId}", style: metadataLabelStyle),
        if (widget.recipe?.createdAt != null)
          Text(
            "Erstellt: ${Format.date(widget.recipe!.createdAt)}",
            style: metadataLabelStyle,
          ),
        if (widget.recipe?.updatedAt != null)
          Text(
            "Bearbeitet: ${Format.date(widget.recipe!.updatedAt)}",
            style: metadataLabelStyle,
          ),
      ],
    ),
  );

  Future<void> _pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() => image = picked);
        imageId = null;
      }
    } catch (e) {
      logger.e("Error when picking image", error: e);
      return;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final ingredientModels = ingredients
        .where((i) => i.name.text.trim().isNotEmpty)
        .map(
          (i) => Ingredient(
            name: i.name.text.trim(),
            amount: Format.parseString(i.amount.text),
            unit: i.unit,
          ),
        )
        .toList();

    final nutritionModels = nutritions
        .where((i) => i.name.text.trim().isNotEmpty)
        .map(
          (i) => Nutrition(
            name: i.name.text.trim(),
            amount: Format.parseString(i.amount.text),
            unit: i.unit,
          ),
        )
        .toList();

    final recipeUri = linkCtrl.text != "" ? linkCtrl.text : null;

    final recipe = Recipe(
      title: titleCtrl.text,
      imageId: imageId,
      description: descCtrl.text,
      timePrep: int.tryParse(timePrepCtrl.text),
      timeTotal: int.tryParse(timeTotalCtrl.text),
      portions: Format.parseString(portionsCtrl.text),
      recipeUri: recipeUri,

      ingredients: ingredientModels,
      nutritions: nutritionModels,

      image: image,
    );

    Navigator.pop(context, recipe);
  }
}

class IngredientOrNutritionDraft {
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();
  String? unit = "g";

  IngredientOrNutritionDraft({String? name, double? amount, this.unit}) {
    if (name != null) {
      this.name.text = name;
    }
    if (amount != null) {
      this.amount.text = Format.number(amount);
    }
  }
}
