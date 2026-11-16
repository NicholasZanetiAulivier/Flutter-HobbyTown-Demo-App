import 'package:flutter/material.dart';
import 'package:hobby_town_demo/constants/colors.dart';

class FilterChipWrapper extends StatelessWidget {
  const FilterChipWrapper({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? INK : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? INK : const Color(0xFFE4E2EC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : INK,
          ),
        ),
      ),
    );
  }
}
