import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../widgets/book_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search for a book, author, category...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => context.read<AppState>().search(v),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickSearchChip(label: 'العادات الذرية', controller: _controller),
                    const SizedBox(width: 8),
                    _QuickSearchChip(label: 'روايات عربية', controller: _controller),
                    const SizedBox(width: 8),
                    _QuickSearchChip(label: 'تنمية بشرية', controller: _controller),
                    const SizedBox(width: 8),
                    _QuickSearchChip(label: 'كتب أطفال', controller: _controller),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Search Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, app, child) {
                    if (app.books.isEmpty) {
                      return const Center(
                        child: Text('No matching results found'),
                      );
                    }
                    return GridView.builder(
                      itemCount: app.books.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) => BookCard(
                        book: app.books[index],
                        compact: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickSearchChip extends StatelessWidget {
  const _QuickSearchChip({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        controller.text = label;
        context.read<AppState>().search(label);
      },
    );
  }
}
