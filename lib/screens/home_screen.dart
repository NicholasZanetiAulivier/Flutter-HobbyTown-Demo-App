import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_town_demo/components/floating_app_bar.dart';
import 'package:hobby_town_demo/components/top_app_bar.dart';
import 'package:hobby_town_demo/providers/auth_provider.dart';
import 'package:hobby_town_demo/screens/cart_screen.dart';
import 'package:hobby_town_demo/screens/catalog_screen.dart';
import 'package:hobby_town_demo/screens/general_screen.dart';
import 'package:hobby_town_demo/screens/profile_screen.dart';
import 'package:hobby_town_demo/screens/wishlist_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;
  String titleText = "Beranda";
  late Widget currentPage;
  final BottomBarController controller = BottomBarController();

  final List<Widget> pages = <Widget>[
    GeneralScreen(),
    CatalogScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  void onNavPick(int i) {
    switch (i) {
      case 0:
        {
          currentPage = pages[0];
          titleText = "Beranda";
          break;
        }
      case 1:
        {
          currentPage = pages[1];
          titleText = "Katalog";
          break;
        }
      case 2:
        {
          if (!ref.watch(isAuthSelector)) {
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(content: Text("You must be logged in to view")),
            );
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => CartScreen()));
          }
          break;
        }
      case 3:
        {
          currentPage = pages[2];
          titleText = "Wishlist";
          break;
        }
      case 4:
        {
          currentPage = pages[3];
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
  void initState() {
    super.initState();
    setState(() {
      currentPage = pages[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 40,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: TopAppBarContent(
            titleText: titleText,
            shouldShowBackButton: false,
          ),
        ),
        body: BottomBar(
          controller: controller,
          scrollBehavior: BottomBarScrollBehavior(
            showAtStart: true,
            showOnScrollEnd: true,
            hideOnScroll: true,
          ),
          body: currentPage,
          child: FloatingAppBar(setIndexCallback: onNavPick),
        ),
      ),
    );
  }
}
