import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/providers/auth_provider.dart';
import 'package:hobby_town_demo/screens/splash_screen.dart';
import 'package:hobby_town_demo/services/globals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsync sharedPreferences = SharedPreferencesAsync();
  GlobalsService.isAuth = await sharedPreferences.getBool("isAuth") ?? false;
  GlobalsService.username = await sharedPreferences.getString("username") ?? "";

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(isAuthProvider.notifier).state = GlobalsService.isAuth;
    ref.read(usernameProvider.notifier).state = GlobalsService.username;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Color(0xFFF8F7FA)),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
          displayLarge: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
          displayMedium: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          labelSmall: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 8,
          ),
          labelMedium: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: MAROON_PINK,
          ),
          headlineMedium: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.normal,
            fontSize: 10,
            color: TEXT_GREY,
          ),
          labelLarge: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: MAROON_PINK,
          ),
          headlineSmall: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
          titleMedium: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          displaySmall: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: Color(0xFF6B6B76),
          ),
          titleSmall: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          titleLarge: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
