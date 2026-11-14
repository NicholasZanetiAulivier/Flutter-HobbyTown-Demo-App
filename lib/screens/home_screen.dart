import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:hobby_town_demo/components/floating_app_bar.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/screens/cart_screen.dart';
import 'package:hobby_town_demo/screens/catalog_screen.dart';
import 'package:hobby_town_demo/screens/general_screen.dart';
import 'package:hobby_town_demo/screens/profile_screen.dart';
import 'package:hobby_town_demo/screens/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  final List<Widget> pages = const <Widget>[
    GeneralScreen(),
    CatalogScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String titleText = "Beranda";
  late Widget currentPage;

  void onNavPick(int i) {
    switch (i) {
      case 0:
        {
          currentPage = widget.pages[0];
          titleText = "Beranda";
          break;
        }
      case 1:
        {
          currentPage = widget.pages[1];
          titleText = "Katalog";
          break;
        }
      case 2:
        {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CartScreen()));
          break;
        }
      case 3:
        {
          currentPage = widget.pages[2];
          titleText = "Wishlist";
          break;
        }
      case 4:
        {
          currentPage = widget.pages[3];
          titleText = "Akun Saya";
          break;
        }
      default:
        {
          onNavPick(0);
          return;
        }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      currentPage = widget.pages[0];
    });
    return Scaffold(
      appBar: AppBar(
        title: TopAppBarContent(
          titleText: titleText,
          shouldShowBackButton: false,
        ),
      ),
      body: BottomBar(
        body: currentPage,
        child: FloatingAppBar(setIndexCallback: onNavPick),
      ),
    );
  }
}
