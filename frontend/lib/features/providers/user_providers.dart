import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/user.dart';
import 'package:frontend/features/data/services/user_service.dart';

final userServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return UserService(client);
});

final userRepositoryProvider =
    NotifierProvider<UserRepositoryNotifier, Map<int, UserSimple>>(
      UserRepositoryNotifier.new,
    );

class UserRepositoryNotifier extends Notifier<Map<int, UserSimple>> {
  late final _userService = ref.read(userServiceProvider);

  @override
  Map<int, UserSimple> build() {
    return {};
  }

  Future<UserSimple> getUserInfo(int userId) async {
    final cached = state[userId];
    if (cached != null) return cached;

    final fetched = await _userService.getUserInfoFromUser(userId);
    state = {...state, userId: fetched};
    return fetched;
  }
}

final userProvider = FutureProvider.family<UserSimple, int>((ref, userId) {
  ref.watch(userRepositoryProvider);
  return ref.read(userRepositoryProvider.notifier).getUserInfo(userId);
});
