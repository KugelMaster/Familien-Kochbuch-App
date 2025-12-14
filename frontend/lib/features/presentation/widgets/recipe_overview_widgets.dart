import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/features/data/models/ingredient.dart';
import 'package:frontend/features/data/models/nutrition.dart';
import 'package:frontend/features/data/models/rating.dart';
import 'package:frontend/features/data/models/recipe.dart';
import 'package:frontend/features/data/models/usernote.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeOverviewWidgets {
  static Widget buildImage({
    required Future<void> Function() getPhoto,
    required double screenHeight,
    String? imageUrl,
    XFile? pickedImage,
  }) {
    final height = screenHeight * 0.6;
    final Widget imageOrFiller;

    // PRIORITY:
    // 1. Pick image taken from user
    if (pickedImage != null) {
      imageOrFiller = Image.file(File(pickedImage.path), fit: BoxFit.cover);
    }
    // 2. Display image from the url
    else if (imageUrl != null) {
      imageOrFiller = Image.network(imageUrl, fit: BoxFit.cover);
    }
    // 3. Display a filler
    else {
      imageOrFiller = InkWell(
        onTap: getPhoto,
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

  static Widget buildTags(List<String> tags) {
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

  static Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        description,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  static Widget buildRatingSummary(List<Rating> ratings) {
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

  static Widget buildInfoChips(Recipe recipe, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.timer, color: iconColor),
          const SizedBox(width: 6),
          Text(_formatTime(recipe.timePrep)),

          const SizedBox(width: 12),
          Container(width: 1, height: 16, color: Colors.grey.shade500),
          const SizedBox(width: 12),

          Icon(Icons.schedule, color: iconColor),
          const SizedBox(width: 6),
          Text(_formatTime(recipe.timeTotal)),

          const SizedBox(width: 12),
          Container(width: 1, height: 16, color: Colors.grey.shade500),
          const SizedBox(width: 12),

          Icon(Icons.fastfood, color: iconColor),
          const SizedBox(width: 6),
          Text(_formatPortion(recipe.portions)),
        ],
      ),
    );
  }

  static Widget buildUriButton(String uri) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text("Originalrezept öffnen"),
        onPressed: () async {
          if (!await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication)) {
            throw Exception("Could not launch $uri");
          }
        },
      ),
    );
  }

  static List<Widget> buildIngredients(List<Ingredient> ingredients) {
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

  static List<Widget> buildNutritions(List<Nutrition>? nutritions) {
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

  static Widget buildUserNotes(List<UserNote> usernotes) {
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


  static String _formatNoteDate(UserNote n) {
    final created =
        "${n.createdAt.day}.${n.createdAt.month}.${n.createdAt.year}";
    final updated = n.updatedAt != n.createdAt ? " (bearbeitet)" : "";
    return "Erstellt am $created$updated";
  }

  static String _formatTime(int? time) {
    if (time == null) {
      return "N/A";
    }

    final int hours = time ~/ 60;
    final int minutes = time % 60;

    return "${hours == 0 ? "" : "$hours Std. "}$minutes Min";
  }

  static String _formatPortion(double? portions) {
    if (portions == null) {
      return "N/A Stück";
    }

    String rounded = portions.toStringAsFixed(1);
    return "${rounded.endsWith(".0") ? rounded.substring(0, rounded.length - 2) : rounded} Stück";
  }
}
