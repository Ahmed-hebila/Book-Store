import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'owner_dashboard_page.dart';
import 'publisher_dashboard_page.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    
    if (app.isOwner) return const OwnerDashboardPage();
    if (app.isPublisher) return const PublisherDashboardPage();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: app.tab,
          children: const [
            ProfilePage(),
            CartPage(),
            FavoritesPage(),
            SearchPage(),
            HomePage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: app.tab,
          onDestinationSelected: app.setTab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'My Account'),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
            NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Whishlist'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          ],
        ),
      ),
    );
  }
}
