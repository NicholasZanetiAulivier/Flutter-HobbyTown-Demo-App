import 'dart:async';
import 'dart:convert';

import 'package:hobby_town_demo/models/item.dart';
import 'package:hobby_town_demo/models/news.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String BASE_ROUTE =
      "https://store-api.jubelio.com/webstore/public/v1";
  static final Map<String, String> HEADERS = {
    "Origin": "https://tokocosplay.myhobbytown.com",
  };

  static Future<List<Item>> getItemsAll() async {
    dynamic res = await http
        .get(
          headers: HEADERS,
          Uri.parse(
            "${ApiService.BASE_ROUTE}/product/store/collections/all-products?pageSize=50",
          ),
        )
        .then((value) {
          if (value.statusCode == 200)
            return jsonDecode(value.body);
          else
            return null;
        });
    return res == null
        ? <Item>[]
        : (res["data"] as dynamic).map<Item>((e) => Item.fromJson(e)).toList()
              as List<Item>;
  }

  static Future<List<News>> getNewsAll() async {
    dynamic res = await http
        .get(
          headers: HEADERS,
          Uri.parse(
            "${ApiService.BASE_ROUTE}/sites/blogs/public/anime-manga-news?page=1&pageSize=50",
          ),
        )
        .then((value) {
          if (value.statusCode == 200)
            return jsonDecode(value.body);
          else
            return null;
        });
    return res == null
        ? <News>[]
        : (res["data"] as dynamic).map<News>((e) => News.fromJson(e)).toList()
              as List<News>;
  }
}
