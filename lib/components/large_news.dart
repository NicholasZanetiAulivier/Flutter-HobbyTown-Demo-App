import 'package:flutter/material.dart';

class LargeNews extends StatelessWidget {
  const LargeNews({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.dateReleased,
    required this.readMinutes,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final DateTime dateReleased;
  final int readMinutes;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),
            child: Image.network(
              imageUrl,
              height: 216,
              width: 342,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(height: 12),
          Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Text(
              "${dateReleased.day}-${dateReleased.month}-${dateReleased.year} \u00B7 ${readMinutes} menit baca",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}
