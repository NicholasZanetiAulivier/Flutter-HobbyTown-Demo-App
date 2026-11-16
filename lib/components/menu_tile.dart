import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/menu_item_data.dart';

class MenuTile extends StatelessWidget {
  const MenuTile({required this.data});

  final MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2F7),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 20, color: INK),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: INK,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: const TextStyle(fontSize: 12, color: MUTED),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF4A4756),
            ),
          ],
        ),
      ),
    );
  }
}
