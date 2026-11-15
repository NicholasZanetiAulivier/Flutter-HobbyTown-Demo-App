import 'package:flutter/material.dart';

class SmallNews extends StatelessWidget {
  const SmallNews({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.dateReleased,
    required this.readMinutes,
    required this.category,
    required this.onTap,
  });

  final String imageUrl;
  final String category;
  final String title;
  final DateTime dateReleased;
  final int readMinutes;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),
            child: Image.network(
              imageUrl,
              height: 120,
              width: 104,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: Theme.of(context).textTheme.labelMedium),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                Text(
                  "${dateReleased.day}-${dateReleased.month}-${dateReleased.year} \u00B7 ${readMinutes} menit baca",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
