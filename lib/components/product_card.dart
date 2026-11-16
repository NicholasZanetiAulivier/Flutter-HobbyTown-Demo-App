import 'package:flutter/material.dart';
import 'package:hobby_town_demo/constants/colors.dart';
import 'package:hobby_town_demo/utils/utils.dart';

import '../models/item.dart';
import 'circle_button.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.item,
    required this.onTap,
    required this.onRemoveFavorite,
    required this.onAddToCart,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onRemoveFavorite;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(item.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleButton(
                    size: 32,
                    color: Colors.white,
                    onTap: onRemoveFavorite,
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 17,
                      color: PINK,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: CircleButton(
                    size: 34,
                    color: INK,
                    onTap: onAddToCart,
                    child: const Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: INK,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            intToRupiah(item.price),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: INK,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: MUTED),
          ),
        ],
      ),
    );
  }
}
