import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../widgets/app_input.dart';

class PublisherDashboardPage extends StatelessWidget {
  const PublisherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Publisher Dashboard'),
          actions: [
            IconButton(
              onPressed: () => context.read<AppState>().refreshPublisherData(),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () => context.read<AppState>().logout(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddProductDialog(context),
          child: const Icon(Icons.add),
        ),
        body: Consumer<AppState>(
          builder: (context, app, child) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('My Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (app.publisherProducts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No products added yet'),
                  ),
                ),
              ...app.publisherProducts.map((product) => Card(
                    child: ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl,
                              width: 40, height: 40, fit: BoxFit.cover)
                          : const Icon(Icons.book),
                      title: Text(product.title),
                      subtitle: Text('Status: ${product.stock > 0 ? "Available" : "Unavailable"}'),
                      trailing: Text('${product.price} ج.م'),
                    ),
                  )),
              const SizedBox(height: 24),
              const Text('Orders on My Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (app.publisherOrders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No Current Orders'),
                  ),
                ),
              ...app.publisherOrders.map((order) {
                return Card(
                  child: ListTile(
                    title: Text('Order #${order['id'].toString().substring(0, 8)}'),
                    subtitle: Text('Customer: ${order['customerName']}'),
                    trailing: Text('${order['status'] ?? "In Progress"}'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final title = TextEditingController();
    final author = TextEditingController();
    final price = TextEditingController();
    final category = TextEditingController(text: 'Novels');
    final imageUrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(controller: title, hint: 'Product Name'),
              AppInput(controller: author, hint: 'Author'),
              AppInput(controller: price, hint: 'Price', keyboardType: TextInputType.number),
              AppInput(controller: category, hint: 'Category'),
              AppInput(controller: imageUrl, hint: 'Image URL'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().addPublisherProduct(
                      title: title.text,
                      author: author.text,
                      price: int.tryParse(price.text) ?? 0,
                      category: category.text,
                      imageUrl: imageUrl.text,
                    );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product Addition Faild')),
                  );
                }
              }
            },
            child: const Text('Submit for Review'),
          ),
        ],
      ),
    );
  }
}
