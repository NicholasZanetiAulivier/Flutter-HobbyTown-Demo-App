import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

final isAuthState = StateProvider<bool>((_) => false);

final isAuthProvider = Provider<bool>((ref) {
  return ref.watch(isAuthState);
});

final usernameState = StateProvider<String>((_) => "unknown");

final usernameProvider = Provider<String>((ref) => ref.watch(usernameState));
