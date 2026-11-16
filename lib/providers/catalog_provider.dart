import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/item.dart';

final itemsState = StateProvider<List<Item>>(
  (_) => [
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
    ),
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
    ),
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
    ),
    Item(
      imageUrl: "https://store-assets.jubelio.com/webstore-v2/images/jstorev2/t1578dbnhqmov/1775878199359_a9465fd0-c757-47d6-9350-94a122409cef.jpeg",
      category: "Liontin",
      name: "Kalung Anime Ansatsu Assassination Classroom",
      id: "1",
      price: 43750,
      released: DateTime.now(),
    ),
  ],
);

final itemsProvider = Provider<List<Item>>((ref) => ref.watch(itemsState));

final wishState = StateProvider<List<Item>>((ref) => []);

final wishProvider = Provider<List<Item>>((ref) => ref.watch(wishState));

final historyState = StateProvider<List<String>>((_) => []);

final historyProvider = Provider<List<String>>(
  (ref) => ref.watch(historyState),
);
