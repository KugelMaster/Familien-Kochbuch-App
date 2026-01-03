import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/async_value_handler.dart';
import 'package:frontend/features/providers/image_providers.dart';

class RecipeImage extends ConsumerWidget {
  final int? imageId;

  const RecipeImage({super.key, required this.imageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(imageProvider(imageId));

    return AsyncValueHandler(
      asyncValue: imageAsync,
      onData: (image) => Hero(
        tag: "recipe-image-$imageId",
        child: image != null
            ? Image.file(
                File(image.path),
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
