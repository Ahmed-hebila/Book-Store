import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../data/models/book.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cart = appState.cart;
    final List<dynamic> items = cart['items'] ?? [];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shpping Cart',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${items.length} Product',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Cart is Empty',
                          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final bookId = item['bookId'];
                          final book = appState.allBooks.firstWhere((b) => b.id == bookId, orElse: () => appState.books.firstWhere((b) => b.id == bookId));
                          return _CartItemTile(item: item, book: book);
                        },
                      ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                _CartSummary(cart: cart),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _handleCheckout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    try {
      await context.read<AppState>().checkout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order Confirmed!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order Faild!')),
        );
      }
    }
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.book});
  final Map<String, dynamic> item; 
  final Book book;

  @override
  Widget build(BuildContext context) {
    final int quantity = item['quantity'] ?? 1;
    final double price = (item['price'] ?? book.price).toDouble();
    final double lineTotal = price * quantity;
    
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              clipBehavior: Clip.antiAlias,
              child: book.imageUrl.isNotEmpty
                  ? Image.network(book.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.book),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lineTotal EGP',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _qtyButton(
                        context,
                        Icons.remove,
                        () => context
                            .read<AppState>()
                            .setCartQuantity(book.id, quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _qtyButton(
                        context,
                        Icons.add,
                        () => context
                            .read<AppState>()
                            .setCartQuantity(book.id, quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => context.read<AppState>().removeFromCart(book.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});
  final Map<String, dynamic> cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _summaryRow(context, 'Subtotal', '${cart['subtotal']} EGP'),
          const SizedBox(height: 8),
          _summaryRow(context, 'Shipping Fee', '${cart['shipping']} EGP'),
          const Divider(height: 24),
          _summaryRow(
            context,
            'Total',
            '${cart['total']} EGP',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
