import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();
final List<Map<String, dynamic>> _users = [
  {
    'id': 'u1',
    'name': 'Ahmed Mohamed',
    'email': 'ahmed@email.com',
    'password': '12345678',
    'role': 'customer',
    'publisherId': null,
    'points': 156,
    'orders': 24,
    'favorites': 12,
  },
  {
    'id': 'owner1',
    'name': 'Store Owner',
    'email': 'owner@store.com',
    'password': '12345678',
    'role': 'owner',
    'publisherId': null,
    'points': 0,
    'orders': 0,
    'favorites': 0,
  },
  {
    'id': 'pub-user-1',
    'name': 'Dar Publisher',
    'email': 'publisher@store.com',
    'password': '12345678',
    'role': 'publisher',
    'publisherId': 'p1',
    'points': 0,
    'orders': 0,
    'favorites': 0,
  },
];

final List<Map<String, dynamic>> _books = [
  {
    'id': 'b1',
    'title': 'ألف ليلة وليلة',
    'author': 'مجهول',
    'price': 120,
    'oldPrice': 150,
    'rating': 4.8,
    'reviewsCount': 234,
    'category': 'روايات',
    'color': '#9B5A24',
    'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=800&q=80',
    'stock': 18,
    'publisherId': 'p1',
    'approvalStatus': 'approved',
  },
  {
    'id': 'b2',
    'title': 'العادات الذرية',
    'author': 'جيمس كلير',
    'price': 89,
    'oldPrice': 0,
    'rating': 4.9,
    'reviewsCount': 811,
    'category': 'تنمية',
    'color': '#2EA3DE',
    'imageUrl': 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=800&q=80',
    'stock': 22,
    'publisherId': 'p1',
    'approvalStatus': 'approved',
  },
  {
    'id': 'b3',
    'title': 'فن اللامبالاة',
    'author': 'مارك مانسون',
    'price': 75,
    'oldPrice': 0,
    'rating': 4.5,
    'reviewsCount': 423,
    'category': 'تنمية',
    'color': '#FF7A1A',
    'imageUrl': 'https://images.unsplash.com/photo-1473755504818-b72b6dfdc226?auto=format&fit=crop&w=800&q=80',
    'stock': 14,
    'publisherId': 'p1',
    'approvalStatus': 'approved',
  },
  {
    'id': 'b4',
    'title': 'قواعد العشق الأربعون',
    'author': 'إليف شافاق',
    'price': 110,
    'oldPrice': 0,
    'rating': 4.7,
    'reviewsCount': 678,
    'category': 'روايات',
    'color': '#E64AA5',
    'imageUrl': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=800&q=80',
    'stock': 13,
    'publisherId': 'p1',
    'approvalStatus': 'approved',
  },
  {
    'id': 'b5',
    'title': 'أحلام يقظة',
    'author': 'أحمد خالد توفيق',
    'price': 95,
    'oldPrice': 120,
    'rating': 4.4,
    'reviewsCount': 301,
    'category': 'روايات عربية',
    'color': '#5C6A84',
    'imageUrl': 'https://images.unsplash.com/photo-1531901599143-df5010ab9438?auto=format&fit=crop&w=800&q=80',
    'stock': 9,
    'publisherId': 'p1',
    'approvalStatus': 'approved',
  },
  {
    'id': 'b6',
    'title': 'كتب أطفال مصورة',
    'author': 'دار المعرفة',
    'price': 60,
    'oldPrice': 0,
    'rating': 4.6,
    'reviewsCount': 128,
    'category': 'أطفال',
    'color': '#87C4A3',
    'imageUrl': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=800&q=80',
    'stock': 25,
    'publisherId': 'p1',
    'approvalStatus': 'approved',
  },
];

final List<Map<String, dynamic>> _orders = [];

final Map<String, List<Map<String, dynamic>>> _cartByUser = {
  'u1': [
    {'bookId': 'b1', 'quantity': 1},
    {'bookId': 'b2', 'quantity': 2},
  ],
};

final Map<String, List<String>> _favoritesByUser = {
  'u1': ['b1', 'b3'],
};

final Map<String, String> _tokenToUserId = {};

Response _json(Object body, {int status = 200}) => Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Future<Map<String, dynamic>> _body(Request request) async {
  final content = await request.readAsString();
  if (content.isEmpty) return {};
  return jsonDecode(content) as Map<String, dynamic>;
}

Map<String, dynamic>? _currentUser(Request request) {
  final auth = request.headers['authorization'];
  if (auth == null || !auth.startsWith('Bearer ')) return null;
  final token = auth.replaceFirst('Bearer ', '');
  final userId = _tokenToUserId[token];
  if (userId == null) return null;
  return _users.firstWhere((u) => u['id'] == userId, orElse: () => {});
}

bool _isOwner(Map<String, dynamic> user) => user['role'] == 'owner';
bool _isPublisher(Map<String, dynamic> user) => user['role'] == 'publisher';

String _publisherName(String? publisherId) {
  if (publisherId == null || publisherId.isEmpty) return 'Unknown Publisher';
  final match = _users.where((u) => u['publisherId'] == publisherId).toList();
  if (match.isEmpty) return publisherId;
  return (match.first['name'] ?? publisherId).toString();
}

Map<String, dynamic> _ownerReports() {
  var totalRevenue = 0;
  var totalItemsSold = 0;

  final Map<String, Map<String, dynamic>> byPublisher = {};
  final Map<String, int> topBooks = {};

  for (final order in _orders) {
    final items = (order['items'] as List<dynamic>).cast<Map<String, dynamic>>();
    totalRevenue += (order['total'] as num).toInt();
    for (final item in items) {
      final publisherId = (item['publisherId'] ?? '').toString();
      final publisher = byPublisher.putIfAbsent(
        publisherId,
        () => {
          'publisherId': publisherId,
          'publisherName': _publisherName(publisherId),
          'orders': 0,
          'itemsSold': 0,
          'revenue': 0,
        },
      );

      final qty = (item['quantity'] as num).toInt();
      final lineTotal = (item['lineTotal'] as num).toInt();
      totalItemsSold += qty;
      publisher['itemsSold'] = (publisher['itemsSold'] as int) + qty;
      publisher['revenue'] = (publisher['revenue'] as int) + lineTotal;
      publisher['orders'] = (publisher['orders'] as int) + 1;

      final title = (item['title'] ?? 'Unknown').toString();
      topBooks[title] = (topBooks[title] ?? 0) + qty;
    }
  }

  final topBooksList = topBooks.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topPublishers = byPublisher.values.toList()
    ..sort((a, b) => (b['revenue'] as int).compareTo(a['revenue'] as int));

  return {
    'overview': {
      'totalOrders': _orders.length,
      'totalRevenue': totalRevenue,
      'totalItemsSold': totalItemsSold,
      'pendingProducts': _books.where((b) => b['approvalStatus'] == 'pending').length,
      'approvedProducts': _books.where((b) => b['approvalStatus'] == 'approved').length,
      'rejectedProducts': _books.where((b) => b['approvalStatus'] == 'rejected').length,
    },
    'topPublishers': topPublishers.take(5).toList(),
    'topBooks': topBooksList
        .take(5)
        .map((e) => {'title': e.key, 'quantity': e.value})
        .toList(),
  };
}

Map<String, dynamic> _bookById(String id) =>
    _books.firstWhere((b) => b['id'] == id, orElse: () => {});

Map<String, dynamic> _cartSummary(String userId) {
  final items = _cartByUser[userId] ?? [];
  var subtotal = 0;
  final mapped = items.map((item) {
    final book = _bookById(item['bookId'] as String);
    final quantity = item['quantity'] as int;
    final price = (book['price'] as num).toInt();
    subtotal += price * quantity;
    return {
      'book': book,
      'quantity': quantity,
      'lineTotal': price * quantity,
    };
  }).toList();
  const shipping = 25;
  return {
    'items': mapped,
    'subtotal': subtotal,
    'shipping': shipping,
    'total': subtotal + shipping,
  };
}

void main() async {
  final router = Router()
    ..post('/auth/register', (Request request) async {
      final data = await _body(request);
      final email = (data['email'] ?? '').toString().trim().toLowerCase();
      final exists = _users.any((u) => (u['email'] as String) == email);
      if (exists) return _json({'message': 'Email already exists'}, status: 400);

      final user = {
        'id': _uuid.v4(),
        'name': data['name'] ?? 'مستخدم جديد',
        'email': email,
        'password': data['password'] ?? '12345678',
        'role': data['role'] ?? 'customer',
        'publisherId': data['publisherId'],
        'points': 0,
        'orders': 0,
        'favorites': 0,
      };
      _users.add(user);
      _cartByUser[user['id'] as String] = [];
      _favoritesByUser[user['id'] as String] = [];
      final token = _uuid.v4();
      _tokenToUserId[token] = user['id'] as String;

      return _json({
        'token': token,
        'user': {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'role': user['role'],
          'publisherId': user['publisherId'],
          'points': user['points'],
          'orders': user['orders'],
          'favorites': user['favorites'],
        }
      });
    })
    ..post('/auth/login', (Request request) async {
      final data = await _body(request);
      final email = (data['email'] ?? '').toString().trim().toLowerCase();
      final password = (data['password'] ?? '').toString();

      final user = _users.where((u) {
        return (u['email'] as String) == email && (u['password'] as String) == password;
      }).toList();

      if (user.isEmpty) {
        return _json({'message': 'Invalid credentials'}, status: 401);
      }
      final current = user.first;
      final token = _uuid.v4();
      _tokenToUserId[token] = current['id'] as String;
      return _json({
        'token': token,
        'user': {
          'id': current['id'],
          'name': current['name'],
          'email': current['email'],
          'role': current['role'],
          'publisherId': current['publisherId'],
          'points': current['points'],
          'orders': current['orders'],
          'favorites': (_favoritesByUser[current['id']] ?? []).length,
        },
      });
    })
    ..get('/books', (Request request) {
      final q = request.url.queryParameters['q']?.trim().toLowerCase() ?? '';
      final category = request.url.queryParameters['category']?.trim() ?? '';

      final results = _books.where((book) {
        final title = (book['title'] as String).toLowerCase();
        final author = (book['author'] as String).toLowerCase();
        final categoryMatch = category.isEmpty || book['category'] == category;
        final searchMatch = q.isEmpty || title.contains(q) || author.contains(q);
        return categoryMatch &&
            searchMatch &&
            (book['approvalStatus'] == 'approved');
      }).toList();
      return _json({'data': results});
    })
    ..post('/checkout', (Request request) async {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      final userId = user['id'] as String;
      final cartItems = _cartByUser[userId] ?? [];
      if (cartItems.isEmpty) {
        return _json({'message': 'Cart is empty'}, status: 400);
      }

      final lines = <Map<String, dynamic>>[];
      var total = 0;
      for (final item in cartItems) {
        final book = _bookById(item['bookId'] as String);
        if (book.isEmpty || book['approvalStatus'] != 'approved') continue;
        final qty = item['quantity'] as int;
        final price = (book['price'] as num).toInt();
        total += price * qty;
        lines.add({
          'bookId': book['id'],
          'title': book['title'],
          'publisherId': book['publisherId'],
          'quantity': qty,
          'price': price,
          'lineTotal': price * qty,
        });
      }
      if (lines.isEmpty) {
        return _json({'message': 'No valid items'}, status: 400);
      }

      final order = {
        'id': _uuid.v4(),
        'customerId': userId,
        'customerName': user['name'],
        'status': 'new',
        'items': lines,
        'total': total + 25,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _orders.add(order);
      _cartByUser[userId] = [];
      user['orders'] = (user['orders'] as int) + 1;
      return _json({'message': 'Order placed', 'order': order});
    })
    ..get('/cart', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      return _json(_cartSummary(user['id'] as String));
    })
    ..post('/cart', (Request request) async {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      final data = await _body(request);
      final userId = user['id'] as String;
      final bookId = data['bookId'] as String;
      final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

      final list = _cartByUser[userId] ?? [];
      final idx = list.indexWhere((e) => e['bookId'] == bookId);
      if (idx >= 0) {
        list[idx]['quantity'] = quantity;
      } else {
        list.add({'bookId': bookId, 'quantity': quantity});
      }
      _cartByUser[userId] = list;
      return _json(_cartSummary(userId));
    })
    ..delete('/cart/<bookId>', (Request request, String bookId) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      final userId = user['id'] as String;
      final list = _cartByUser[userId] ?? [];
      list.removeWhere((item) => item['bookId'] == bookId);
      _cartByUser[userId] = list;
      return _json(_cartSummary(userId));
    })
    ..get('/favorites', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      final userId = user['id'] as String;
      final ids = _favoritesByUser[userId] ?? [];
      final books = ids.map(_bookById).where((b) => b.isNotEmpty).toList();
      return _json({'data': books});
    })
    ..post('/favorites/toggle/<bookId>', (Request request, String bookId) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      final userId = user['id'] as String;
      final favs = _favoritesByUser[userId] ?? [];
      if (favs.contains(bookId)) {
        favs.remove(bookId);
      } else {
        favs.add(bookId);
      }
      _favoritesByUser[userId] = favs;
      return _json({'favorites': favs});
    })
    ..get('/profile', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty) {
        return _json({'message': 'Unauthorized'}, status: 401);
      }
      final userId = user['id'] as String;
      return _json({
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'role': user['role'],
        'publisherId': user['publisherId'],
        'points': user['points'],
        'orders': user['orders'],
        'favorites': (_favoritesByUser[userId] ?? []).length,
      });
    })
    ..get('/publisher/orders', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isPublisher(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      final publisherId = user['publisherId'] as String;
      final mine = _orders.where((order) {
        final items = (order['items'] as List<dynamic>);
        return items.any((i) => (i as Map<String, dynamic>)['publisherId'] == publisherId);
      }).toList();
      return _json({'data': mine});
    })
    ..post('/publisher/products', (Request request) async {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isPublisher(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      final data = await _body(request);
      final product = {
        'id': _uuid.v4(),
        'title': data['title'] ?? 'منتج جديد',
        'author': data['author'] ?? '',
        'price': data['price'] ?? 0,
        'oldPrice': data['oldPrice'] ?? 0,
        'rating': data['rating'] ?? 0,
        'reviewsCount': data['reviewsCount'] ?? 0,
        'category': data['category'] ?? 'عام',
        'color': data['color'] ?? '#999999',
        'imageUrl': data['imageUrl'] ?? '',
        'stock': data['stock'] ?? 0,
        'publisherId': user['publisherId'],
        'approvalStatus': 'pending',
      };
      _books.add(product);
      return _json({'message': 'Submitted for approval', 'product': product});
    })
    ..get('/publisher/products', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isPublisher(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      final publisherId = user['publisherId'] as String;
      final mine = _books.where((b) => b['publisherId'] == publisherId).toList();
      return _json({'data': mine});
    })
    ..get('/owner/orders', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isOwner(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      return _json({'data': _orders});
    })
    ..get('/owner/reports', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isOwner(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      return _json(_ownerReports());
    })
    ..get('/owner/products/pending', (Request request) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isOwner(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      final pending = _books.where((b) => b['approvalStatus'] == 'pending').toList();
      return _json({'data': pending});
    })
    ..post('/owner/products/<id>/approve', (Request request, String id) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isOwner(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      final idx = _books.indexWhere((b) => b['id'] == id);
      if (idx < 0) return _json({'message': 'Not found'}, status: 404);
      _books[idx]['approvalStatus'] = 'approved';
      return _json({'message': 'Approved'});
    })
    ..post('/owner/products/<id>/reject', (Request request, String id) {
      final user = _currentUser(request);
      if (user == null || user.isEmpty || !_isOwner(user)) {
        return _json({'message': 'Forbidden'}, status: 403);
      }
      final idx = _books.indexWhere((b) => b['id'] == id);
      if (idx < 0) return _json({'message': 'Not found'}, status: 404);
      _books[idx]['approvalStatus'] = 'rejected';
      return _json({'message': 'Rejected'});
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Backend running on http://${server.address.host}:${server.port}');
}
