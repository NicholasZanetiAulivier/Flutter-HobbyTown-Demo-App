import 'package:flutter/material.dart';
import 'package:hobby_town_demo/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          labelSmall: TextStyle(
            fontFamily: "PlusJakartaSans",
            fontWeight: FontWeight.w700,
            fontSize: 8,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
