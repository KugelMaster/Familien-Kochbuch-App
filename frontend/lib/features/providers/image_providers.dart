import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/services/image_service.dart';
import 'package:image_picker/image_picker.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ImageService(client);
});

final imageRepositoryProvider =
    NotifierProvider<ImageRepositoryNotifier, Map<int, XFile>>(
      ImageRepositoryNotifier.new,
    );

class ImageRepositoryNotifier extends Notifier<Map<int, XFile>> {
  late final _imageService = ref.read(imageServiceProvider);

  @override
  Map<int, XFile> build() {
    return {};
  }

  Future<XFile> getImage(int imageId) async {
    final cached = state[imageId];
    if (cached != null) return cached;

    final fetched = await _imageService.getImage(imageId);
    state = {...state, imageId: fetched};

    return fetched;
  }

  Future<int> uploadImage(XFile image, String tag) async {
    final imageId = await _imageService.uploadImage(image, tag);

    state = {...state, imageId: image};

    return imageId;
  }
}

final imageProvider = FutureProvider.family<XFile?, int?>((ref, imageId) async {
  ref.watch(imageRepositoryProvider);
  if (imageId == null) return null;
  return ref.read(imageRepositoryProvider.notifier).getImage(imageId);
});
