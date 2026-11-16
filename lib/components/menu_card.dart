import 'package:flutter/material.dart';

import '../models/menu_item_data.dart';
import 'menu_tile.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({required this.items});

  final List<MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B1530),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [for (final item in items) MenuTile(data: item)]),
    );
  }
}
