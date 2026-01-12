import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/features/presentation/shared/async_image_widget.dart';
import 'package:frontend/features/providers/user_providers.dart';

class AsyncAvatarWidget extends ConsumerWidget {
  final int userId;
  final double? radius;

  const AsyncAvatarWidget({super.key, required this.userId, this.radius});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return userAsync.when(
      data: (user) => AsyncImageWidget(
        imageId: user.avatarId,
        placeholder: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        onData: (image) => CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(File(image.path)),
          backgroundColor: Colors.grey.shade200,
        ),
      ),
      loading: () => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, st) {
        logger.e("Error while fetching user: $e\n$st");

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person),
        );
      },
    );
  }
}
