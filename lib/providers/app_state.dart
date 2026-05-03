import 'package:flutter/material.dart';
import '../data/services/firebase_service.dart';
import '../data/models/book.dart';
import '../data/models/user.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _firebaseService;

  AppState(this._firebaseService);

  String _uid = '';
  User? currentUser;
  List<Book> books = [];
  List<Book> allBooks = [];
  List<Book> favorites = [];
  List<Map<String, dynamic>> cartItems = [];

  List<Book> pendingProducts = [];
  List<Book> publisherProducts = [];

  int tab = 4;
  bool loading = false;

  bool get isLoggedIn => _uid.isNotEmpty;
  bool get isOwner => currentUser?.role == UserRole.owner;
  bool get isPublisher => currentUser?.role == UserRole.publisher;

  User? get user => currentUser;

  Map<String, dynamic> get cart => {
        'items': cartItems,
        'subtotal': _calculateTotal(),
        'shipping': 50.0,
        'total': _calculateTotal() + 50.0,
      };

  double _calculateTotal() {
    double total = 0;
    for (var item in cartItems) {
      double price = (item['price'] ?? 0).toDouble();
      int qty = (item['quantity'] ?? 1);
      total += price * qty;
    }
    return total;
  }

  Future<void> login(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      final credential = await _firebaseService.login(email, password);
      _uid = credential.user?.uid ?? '';
      await preload();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password,
      {String role = 'customer'}) async {
    loading = true;
    notifyListeners();
    try {
      final credential =
          await _firebaseService.register(name, email, password, role: role);
      _uid = credential.user?.uid ?? '';
      await preload();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> preload() async {
    if (_uid.isEmpty) return;

    try {
      final userData = await _firebaseService.fetchProfile(_uid);
      final completeData = {
        'id': _uid,
        'orders': 0,
        'points': 0,
        'favorites_count': 0,
        ...userData
      };
      currentUser = User.fromJson(completeData);

      if (isOwner) {
        pendingProducts = (await _firebaseService.fetchPendingProducts())
            .map((e) => Book.fromJson(e))
            .toList();
      } else if (isPublisher) {
        publisherProducts =
            (await _firebaseService.fetchPublisherProducts(_uid))
                .map((e) => Book.fromJson(e))
                .toList();
      } else {
        final booksData = await _firebaseService.fetchBooks();
        allBooks = booksData.map((e) => Book.fromJson(e)).toList();
        books = List<Book>.from(allBooks);
        cartItems = await _firebaseService.fetchCart(_uid);
        List favIds = userData['favorites'] ?? [];
        favorites = allBooks.where((b) => favIds.contains(b.id)).toList();
      }
    } catch (e) {
      debugPrint("Error preloading: $e");
    } finally {
      notifyListeners();
    }
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void search(String q) {
    if (q.isEmpty) {
      books = List<Book>.from(allBooks);
    } else {
      books = allBooks
          .where((b) =>
              b.title.toLowerCase().contains(q.toLowerCase()) ||
              b.author.toLowerCase().contains(q.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> toggleFav(String bookId) async {
    await _firebaseService.toggleFavorite(_uid, bookId);
    await preload();
  }

  Future<void> addToCart(String bookId, int quantity) async {
    await _firebaseService.updateCart(_uid, bookId, quantity);
    await preload();
  }

  Future<void> removeFromCart(String bookId) async {
    await _firebaseService.removeFromCart(_uid, bookId);
    await preload();
  }

  Future<void> setCartQuantity(String bookId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(bookId);
    } else {
      await _firebaseService.updateCart(_uid, bookId, quantity);
      await preload();
    }
  }

  Future<void> checkout() async {
    for (var item in cartItems) {
      String bookId = item['bookId'];
      await _firebaseService.removeFromCart(_uid, bookId);
    }
    await preload();
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    _uid = '';
    currentUser = null;
    books = [];
    allBooks = [];
    notifyListeners();
  }

  Future<void> addPublisherProduct({
    required String title,
    required String author,
    required int price,
    required String category,
    required String imageUrl,
  }) async {
    await _firebaseService.createProduct(_uid, {
      'title': title,
      'author': author,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
    });
    await preload();
  }

  Future<void> refreshPublisherData() => preload();
  Future<void> refreshOwnerData() => preload();

  Future<void> approveProduct(String bookId) async {
    await _firebaseService.updateProductStatus(bookId, 'approved');
    await preload();
  }

  Future<void> rejectProduct(String bookId) async {
    await _firebaseService.updateProductStatus(bookId, 'rejected');
    await preload();
  }

  List<Book> get ownerPendingProducts => pendingProducts;
  List<Map<String, dynamic>> get ownerOrders => [];
  List<Map<String, dynamic>> get publisherOrders => [];

  Map<String, dynamic> get ownerReports => {
        'overview': {
          'totalOrders': 0,
          'totalRevenue': 0,
          'totalItemsSold': 0,
          'pendingProducts': pendingProducts.length
        },
        'topPublishers': [],
        'topBooks': [],
      };
}
