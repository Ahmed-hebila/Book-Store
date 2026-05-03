import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              onPressed: () => context.read<AppState>().refreshOwnerData(),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () => context.read<AppState>().logout(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Consumer<AppState>(
          builder: (context, app, child) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Store Reports',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _OwnerOverviewCards(reports: app.ownerReports),
              const SizedBox(height: 24),
              const Text('Pinding Approval Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (app.ownerPendingProducts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No pending products'),
                  ),
                ),
              ...app.ownerPendingProducts.map((product) => Card(
                    child: ListTile(
                      title: Text(product.title),
                      subtitle: Text('Author: ${product.author}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => app.approveProduct(product.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => app.rejectProduct(product.id),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              const Text('All Orders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...app.ownerOrders.map((order) {
                return Card(
                  child: ListTile(
                    title: Text('Order #${order['id'].toString().substring(0, 8)}'),
                    subtitle: Text('Customer: ${order['customerName']}'),
                    trailing: Text('${order['total']} EGP'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerOverviewCards extends StatelessWidget {
  const _OwnerOverviewCards({required this.reports});
  final Map<String, dynamic> reports;

  @override
  Widget build(BuildContext context) {
    final overview = (reports['overview'] as Map<String, dynamic>?) ?? {};
    final cards = [
      ('Orders', '${overview['totalOrders'] ?? 0}'),
      ('Revenue', '${overview['totalRevenue'] ?? 0} EGP'),
      ('Item Sold', '${overview['totalItemsSold'] ?? 0}'),
      ('Pending', '${overview['pendingProducts'] ?? 0}'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2,
      children: cards
          .map((c) => Card(
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(c.$1, style: const TextStyle(color: Colors.black54)),
                      Text(c.$2,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
