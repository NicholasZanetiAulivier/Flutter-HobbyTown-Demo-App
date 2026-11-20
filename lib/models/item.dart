import 'package:hobby_town_demo/models/address.dart';

class Item {
  final String imageUrl;
  final String id;
  final String name;
  final int price;
  final String category;
  final DateTime released;
  final String anime;

  const new({
    required this.imageUrl,
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.released,
    required this.anime,
  });
}

enum WishlistFilter { all, available, promo }

class CartEntry {
  final Item item;
  final String size;
  final String variant;
  int quantity;
  final bool selected;

  CartEntry({
    required this.item,
    required this.size,
    required this.variant,
    this.quantity = 1,
    this.selected = true,
  });

  int get lineTotal => item.price * quantity;
}

class Order {
  final List<CartEntry> itemList;
  final int total;
  final String orderNo;
  final String paymentMethod;
  final ShippingOption courier;
  final String trackingNumber;

  final DateTime paidAt;
  final DateTime sentAt;
  final DateTime arrivedAt;

  new({
    required this.itemList,
    required this.total,
    required this.orderNo,
    required this.paidAt,
    required this.paymentMethod,
    required this.courier,
    required this.trackingNumber,
    required this.sentAt,
    required this.arrivedAt,
  });

  OrderStatus get status {
    DateTime now = DateTime.now();
    if (this.paidAt.isBefore(now) && this.sentAt.isAfter(now))
      return OrderStatus.ready;
    else if (this.sentAt.isBefore(now) && this.arrivedAt.isAfter(now))
      return OrderStatus.shipping;
    else
      return OrderStatus.done;
  }

  int get itemCount => itemList.length;

  String get firstItemName => itemList.first.item.name;

  String get imageUrl => itemList.first.item.imageUrl;

  String get firstItemVariant => itemList.first.variant;
}

enum OrderStatus {
  ready(1, "Dibayar"),
  shipping(2, "Dikirim"),
  done(3, "Tiba");

  const OrderStatus(this.value, this.label);

  final int value;
  final String label;
}
