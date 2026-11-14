import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:hobby_town_demo/components/floating_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomBar(
        child: FloatingAppBar(
          setIndexCallback: (i) {
            setState(() {
              currentIndex = i;
            });
          },
        ),
        body: Placeholder(),
      ),
    );
  }
}
