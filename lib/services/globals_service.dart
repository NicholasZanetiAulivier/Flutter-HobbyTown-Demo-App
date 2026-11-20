import 'package:hobby_town_demo/models/address.dart';
import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/models/news.dart';

class GlobalsService {
  static bool isAuth = false;
  static String username = "";
  static List<News> articles = [
    News(
      id: "1",
      heroImageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1792650721507_artikel-dimana_large.webp",
      category: "SomeCategory",
      title: "Di Mana Tempat Beli Merchandise Anime Original di Indonesia?",
      authorName: "woof",
      authorAvatarUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1750391835815_1e5e215d-3160-4e52-8583-84b381d02f1e.png",
      publishedAt: DateTime.now(),
      readMinutes: 12,
      contentHtml: "<body><p>HIIIIII</p><body>",
    ),
  ];

  static List<ShippingAddress> addresses = [];
  static List<Item> items = [];
}
