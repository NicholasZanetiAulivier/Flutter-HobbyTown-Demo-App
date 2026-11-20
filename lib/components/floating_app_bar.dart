import 'package:flutter/material.dart';
import 'package:hobby_town_demo/constants/colors.dart';

class FloatingAppBar extends StatefulWidget {
  const FloatingAppBar({
    super.key,
    required this.setIndexCallback,
    this.currentIndex = 0,
  });

  final int currentIndex;
  final Function setIndexCallback;

  @override
  State<FloatingAppBar> createState() => _FloatingAppBarState();
}

class _FloatingAppBarState extends State<FloatingAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 358),
      height: 76,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        color: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ActionButton(context, Icons.house, "Beranda", 0),
          _ActionButton(context, Icons.grid_view_outlined, "Katalog", 1),
          _ActionButton(context, Icons.shopping_cart, "Keranjang", 2),
          _ActionButton(context, Icons.favorite_border, "Wishlist", 3),
          _ActionButton(context, Icons.person, "Akun", 4),
        ],
      ),
    );
  }

  Widget _ActionButton(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    bool selected = index == widget.currentIndex;
    Size preferredSize = selected ? const Size(60, 60) : const Size(45, 50);
    return PreferredSize(
      preferredSize: preferredSize,
      child: AnimatedContainer(
        width: preferredSize.width,
        height: preferredSize.height,
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 500),
        child: GestureDetector(
          onTap: () {
            setState(() {
              widget.setIndexCallback(index);
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? MAROON_PINK : NAV_ICON_GREY),
              AnimatedDefaultTextStyle(
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: selected ? MAROON_PINK : NAV_LABEL_GREY,
                  fontSize: selected ? 8 : 7,
                ),
                curve: Curves.easeOut,
                duration: Duration(milliseconds: 500),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
