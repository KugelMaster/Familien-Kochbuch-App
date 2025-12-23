import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/providers/recipe_providers.dart';
import 'package:image_picker/image_picker.dart';

class ImageOverviewWidget extends ConsumerWidget {
  final int recipeId;
  final Future<void> Function() takePhoto;
  final double screenHeight;

  const ImageOverviewWidget({
    super.key,
    required this.recipeId,
    required this.takePhoto,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(
      recipeProvider(
        recipeId,
      ).select((recipeAsync) => recipeAsync.whenData((r) => r.image)),
    );

    return imageAsync.when(
      loading: () => SizedBox(
        height: screenHeight * 0.6,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: screenHeight * 0.6,
        child: Center(child: Text("Fehler: $e")),
      ),
      data: (image) => _buildImageWidget(image),
    );
  }

  Widget _buildImageWidget(XFile? image) => SizedBox(
    height: screenHeight * 0.6,
    width: double.infinity,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: image == null
              ? _filler()
              : Image.file(File(image.path), fit: BoxFit.cover),
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

  Widget _filler() => InkWell(
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
