import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/data/services/tag_service.dart';

final tagServiceProvider = Provider<TagService>((ref) {
  final client = ref.watch(apiClientProvider);
  return TagService(client);
});


final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final service = ref.watch(tagServiceProvider);
  return await service.getTags();
});
