import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/item.dart';

final itemsProvider = StateProvider<List<Item>>(
  (_) => [
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
      anime: "SomeAnime",
    ),
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
      anime: "SomeAnime",
    ),
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
      anime: "SomeAnime",
    ),
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
      anime: "SomeAnime",
    ),
  ],
);

final itemsSelector = Provider<List<Item>>((ref) => ref.watch(itemsProvider));

final wishProvider = StateProvider<List<Item>>((ref) => []);

final wishSelector = Provider<List<Item>>((ref) => ref.watch(wishProvider));

final historyProvider = StateProvider<List<String>>((_) => []);

final historySelector = Provider<List<String>>(
  (ref) => ref.watch(historyProvider),
);

final cartProvider = StateProvider<List<CartEntry>>((ref) => []);

final cartSelector = Provider<List<CartEntry>>(
  (ref) => ref.watch(cartProvider),
);

final orderProvider = StateProvider<List<Order>>((ref) => []);
final orderSelector = Provider<List<Order>>((ref) => ref.watch(orderProvider));
