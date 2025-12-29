import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';

final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, int>(CurrentUserIdNotifier.new);
class CurrentUserIdNotifier extends Notifier<int> {
  @override
  int build() => 1; // FIXME: For testing purposes the default user id is 1. Remove after implementing user authentification in the app.

  void setUserId(int userId) => state = userId;
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  return ApiClient(userId);
});
