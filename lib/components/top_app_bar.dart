import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/more_menu_button.dart';
import 'package:hobby_town_demo/providers/auth_provider.dart';
import 'package:hobby_town_demo/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopAppBarContent extends ConsumerWidget {
  const TopAppBarContent({
    super.key,
    required this.titleText,
    required this.shouldShowBackButton,
  });

  final String titleText;
  final bool shouldShowBackButton;

  void onLogin(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> onLogout(BuildContext context, WidgetRef ref) async {
    SharedPreferencesAsync sharedPreferences = SharedPreferencesAsync();
    await sharedPreferences.remove("isAuth");
    await sharedPreferences.remove("username");
    await sharedPreferences.remove("email");
    ref.read(isAuthProvider.notifier).state = false;
    ref.read(usernameProvider.notifier).state = "";
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggedIn = ref.watch(isAuthSelector);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: shouldShowBackButton
              ? Colors.white
              : Colors.transparent,
          child: IconButton(
            onPressed: shouldShowBackButton
                ? () {
                    Navigator.of(context).pop();
                  }
                : null,
            color: Colors.black,
            disabledColor: Colors.transparent,
            icon: Icon(Icons.arrow_back_outlined, size: 20),
          ),
        ),
        Text(titleText, style: Theme.of(context).textTheme.headlineLarge),
        MoreMenuButton(
          isLoggedIn: isLoggedIn,
          onLogin: () => onLogin(context, ref),
          onLogout: () => onLogout(context, ref),
        ),
      ],
    );
  }
}
