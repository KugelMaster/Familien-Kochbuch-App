import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/data/services/tag_service.dart';

final tagServiceProvider = Provider<TagService>((ref) {
  final client = ref.watch(apiClientProvider);
  return TagService(client);
});

final tagRepositoryProvider =
    AsyncNotifierProvider<TagRepositoryNotifier, Map<int, Tag>>(
      TagRepositoryNotifier.new,
    );

class TagRepositoryNotifier extends AsyncNotifier<Map<int, Tag>> {
  late final _tagService = ref.read(tagServiceProvider);

  @override
  Future<Map<int, Tag>> build() async {
    final tagList = await _tagService.getTags();

    return {for (var tag in tagList) tag.id: tag};
  }

  Future<List<Tag>> getTags() async {
    final currentState = await future;

    return currentState.values.toList();
  }

  Future<Tag> createTag(String name) async {
    final created = await _tagService.createTag(name);
    final currentState = await future;

    state = AsyncData({...currentState, created.id: created});

    return created;
  }

  Future<Tag> renameTag(int tagId, String name) async {
    final updated = await _tagService.renameTag(tagId, name);
    final currentState = await future;

    state = AsyncData({...currentState, updated.id: updated});

    return updated;
  }

  Future<void> deleteTag(int id) async {
    await _tagService.deleteTag(id);

    final newState = await future;
    newState.remove(id);
    state = AsyncData(newState);
  }
}

final tagsProvider = FutureProvider((ref) {
  ref.watch(tagRepositoryProvider);
  return ref.read(tagRepositoryProvider.notifier).getTags();
});
