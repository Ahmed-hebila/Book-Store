import 'book.dart';

class Cart {
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double total;

  Cart({
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class CartItem {
  final Book book;
  final int quantity;
  final double lineTotal;

  CartItem({
    required this.book,
    required this.quantity,
    required this.lineTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      book: Book.fromJson(json['book'] as Map<String, dynamic>),
      quantity: (json['quantity'] ?? 0).toInt(),
      lineTotal: (json['lineTotal'] ?? 0).toDouble(),
    );
  }
}
