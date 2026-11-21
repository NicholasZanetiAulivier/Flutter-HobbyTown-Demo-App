import 'package:hobby_town_demo/services/globals_service.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

final isAuthProvider = StateProvider<bool>((_) => GlobalsService.isAuth);

final isAuthSelector = Provider<bool>((ref) {
  return ref.watch(isAuthProvider);
});

final usernameProvider = StateProvider<String>((_) => GlobalsService.username);

final usernameSelector = Provider<String>((ref) => ref.watch(usernameProvider));

final emailProvider = StateProvider<String>((_) => GlobalsService.email);

final emailSelector = Provider<String>((ref) => ref.watch(emailProvider));
