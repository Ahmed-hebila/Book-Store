class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final double oldPrice;
  final double rating;
  final int reviewsCount;
  final String category;
  final String color;
  final int stock;
  final String imageUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.oldPrice = 0,
    this.rating = 0,
    this.reviewsCount = 0,
    required this.category,
    this.color = '#8A5A44',
    this.stock = 0,
    this.imageUrl = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: (json['oldPrice'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: (json['reviewsCount'] ?? 0).toInt(),
      category: (json['category'] ?? '').toString(),
      color: (json['color'] ?? '#8A5A44').toString(),
      stock: (json['stock'] ?? 0).toInt(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'category': category,
      'color': color,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}
