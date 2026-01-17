import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/features/providers/image_providers.dart';
import 'package:image_picker/image_picker.dart';

class AsyncImageWidget extends ConsumerWidget {
  final int? imageId;
  final Widget placeholder;
  final Widget Function(XFile image) onData;

  const AsyncImageWidget({
    super.key,
    required this.imageId,
    required this.placeholder,
    required this.onData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(imageProvider(imageId));

    if (imageId == null) {
      return placeholder;
    }

    return imageAsync.when(
      data: (image) => image != null ? onData(image) : placeholder,
      loading: () => placeholder,
      error: (e, st) {
        logger.d("An error occured when trying to load image: $e\n$st");
        return placeholder;
      },
    );
  }
}
