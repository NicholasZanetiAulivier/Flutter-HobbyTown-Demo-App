import 'package:flutter/material.dart';
import 'package:hobby_town_demo/components/large_news.dart';
import 'package:hobby_town_demo/components/small_news.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final ScrollController controller = ScrollController();

  @override
  void activate() {
    super.activate();
    controller.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            LargeNews(
              imageUrl: "https://tokoanime.myhobbytown.com/wp-content/uploads/2026/10/image-1-1024x576.jpeg",
              title: "Apakah Ada Toko Anime di Tangerang yang Bisa Dikunjungi Langsung dan Melayani Pembelian Online?",
              dateReleased: DateTime(2026, 10, 26),
              readMinutes: 6,
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => Placeholder()));
              },
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Bacaan Terbaru",
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            SizedBox(height: 24),
            SmallNews(
              imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1792650721507_artikel-dimana_large.webp",
              title: "Di Mana Tempat Beli Merchandise Anime Original di Indonesia?",
              dateReleased: DateTime(2026, 10, 22),
              readMinutes: 4,
              category: "Berita",
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => Placeholder()));
              },
            ),
            SizedBox(height: 50),
            Text(
              "-- batas --",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
