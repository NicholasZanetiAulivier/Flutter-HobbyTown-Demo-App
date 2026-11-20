import 'package:hobby_town_demo/services/globals_service.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../models/item.dart';

final itemsProvider = StateProvider<List<Item>>((_) => GlobalsService.items);

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
