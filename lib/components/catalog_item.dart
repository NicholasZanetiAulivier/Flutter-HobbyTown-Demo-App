import 'package:flutter/material.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/utils/utils.dart';

class CatalogItem extends StatelessWidget {
  const CatalogItem({super.key, required this.item});

  final Item item;

  void wishList() {
    debugPrint("wixhlis");
  }

  void addToCart() {
    debugPrint("add");
  }

  void moveToPage() {
    debugPrint("page");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          child: Stack(
            children: [
              GestureDetector(
                onTap: moveToPage,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: 145,
                    height: 180,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.black,
                  child: IconButton(
                    onPressed: addToCart,
                    icon: Icon(Icons.add, color: Colors.white, size: 15),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: wishList,
                    icon: Icon(Icons.favorite_border, size: 15),
                    color: MAROON_PINK,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: moveToPage,
          child: Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truncateStringDots(item.name, 20),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  intToRupiah(item.price),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  item.category,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
