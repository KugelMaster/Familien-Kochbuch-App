import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/data/services/tag_service.dart';

final tagServiceProvider = Provider<TagService>((ref) {
  final client = ref.watch(apiClientProvider);
  return TagService(client);
});

///////////////////////////////////////////////////////////////////////////////

final tagCache = Provider((_) => <int, String>{});

Future<Tag> createNewTag(WidgetRef ref, String name) async {
  final tag = await ref.read(tagServiceProvider).createTag(name);

  ref.read(tagCache)[tag.id] = tag.name;

  return tag;
}

final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final service = ref.watch(tagServiceProvider);
  return await service.getTags();
});

final tagProvider = AsyncNotifierProvider.family<TagNotifier, Tag, int>(
  TagNotifier.new,
);

class TagNotifier extends AsyncNotifier<Tag> {
  final int tagId;

  late final cache = ref.watch(tagCache);

  TagNotifier(this.tagId);

  @override
  Future<Tag> build() async {
    final cached = cache[tagId];

    if (cached != null) {
      return Tag(id: tagId, name: cached);
    }

    final fetched = await ref.read(tagServiceProvider).getById(tagId);
    cache[tagId] = fetched.name;
    return fetched;
  }

  Future<void> updateTag(String name) async {
    try {
      final updated = await ref.read(tagServiceProvider).renameTag(tagId, name);

      cache[tagId] = name;

      state = AsyncData(updated);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTag() async {
    await ref.read(tagServiceProvider).deleteTag(tagId);

    cache.remove(tagId);

    ref.invalidateSelf();
  }
}
