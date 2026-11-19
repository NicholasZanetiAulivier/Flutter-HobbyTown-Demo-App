import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hobby_town_demo/models/address.dart';
import 'package:hobby_town_demo/services/globals_service.dart';

final addressProvider = StateProvider<List<ShippingAddress>>(
  (_) => GlobalsService.addresses,
);

final addressSelector = Provider<List<ShippingAddress>>(
  (ref) => ref.watch(addressProvider),
);
