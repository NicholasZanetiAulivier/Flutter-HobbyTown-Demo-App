import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/screens/home_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
      home: HomeScreen(),
    );
  }
}
