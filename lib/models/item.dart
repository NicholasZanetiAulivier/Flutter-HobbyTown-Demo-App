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
  final int quantity;
  final bool selected;

  const CartEntry({
    required this.item,
    required this.size,
    required this.variant,
    this.quantity = 1,
    this.selected = true,
  });

  int get lineTotal => item.price * quantity;
}
