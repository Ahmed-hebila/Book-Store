import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../widgets/book_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppState>().favorites;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Whishlist',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${favorites.length} Book',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: favorites.isEmpty
                    ? const Center(
                        child: Text(
                          'Your whishlist is currently empty',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : GridView.builder(
                        itemCount: favorites.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.55, 
                        ),
                        itemBuilder: (context, index) => BookCard(book: favorites[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
