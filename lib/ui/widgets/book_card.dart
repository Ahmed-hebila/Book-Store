import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/book.dart';
import '../../providers/app_state.dart';
import '../pages/book_details_page.dart';
import 'book_cover.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, this.compact = false});
  final Book book;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isFavorite = app.favorites.any((f) => f.id == book.id);
    final coverColor = parseHexColor(book.color);

    return Card(
      elevation: 0.6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsPage(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Hero(
                        tag: 'book-${book.id}',
                        child: BookCover(
                          imageUrl: book.imageUrl,
                          title: book.title,
                          color: coverColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(230),
                      radius: 18,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: const Color.fromARGB(255, 59, 204, 90),
                        ),
                        onPressed: () => context.read<AppState>().toggleFav(book.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${book.price} EGP',
                          style: TextStyle(
                            fontSize: compact ? 16 : 18,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(
                          ' ${book.rating}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => context.read<AppState>().addToCart(book.id, 1),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Add to cart', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
