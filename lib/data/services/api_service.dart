import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/user.dart';
import '../models/cart.dart';

class ApiService {
  final String baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(null),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode >= 400) throw Exception('فشل تسجيل الدخول');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(null),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode >= 400) throw Exception('فشل إنشاء الحساب');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Book>> fetchBooks({String q = ''}) async {
    final uri = Uri.parse('$baseUrl/books').replace(
      queryParameters: q.trim().isEmpty ? {} : {'q': q.trim()},
    );
    final response = await http.get(uri);
    if (response.statusCode >= 400) throw Exception('فشل تحميل الكتب');
    final List<dynamic> data = jsonDecode(response.body)['data'];
    return data.map((e) => Book.fromJson(e)).toList();
  }

  Future<Cart> fetchCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل السلة');
    return Cart.fromJson(jsonDecode(response.body));
  }

  Future<void> updateCart(String token, String bookId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: _headers(token),
      body: jsonEncode({'bookId': bookId, 'quantity': quantity}),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحديث السلة');
  }

  Future<void> deleteCartItem(String token, String bookId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$bookId'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل حذف العنصر');
  }

  Future<List<Book>> fetchFavorites(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل المفضلة');
    final List<dynamic> data = jsonDecode(response.body)['data'];
    return data.map((e) => Book.fromJson(e)).toList();
  }

  Future<void> toggleFavorite(String token, String bookId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/toggle/$bookId'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحديث المفضلة');
  }

  Future<User> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل الحساب');
    return User.fromJson(jsonDecode(response.body));
  }

  Future<void> checkout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل إتمام الطلب');
  }

  // Owner methods
  Future<List<dynamic>> ownerOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/owner/orders'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل طلبات المالك');
    return jsonDecode(response.body)['data'] as List<dynamic>;
  }

  Future<List<Book>> ownerPendingProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/owner/products/pending'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل المنتجات المعلقة');
    final List<dynamic> data = jsonDecode(response.body)['data'];
    return data.map((e) => Book.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> ownerReports(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/owner/reports'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل التقارير');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> ownerApprove(String token, String productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/owner/products/$productId/approve'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل الموافقة على المنتج');
  }

  Future<void> ownerReject(String token, String productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/owner/products/$productId/reject'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل رفض المنتج');
  }

  // Publisher methods
  Future<List<dynamic>> publisherOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publisher/orders'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل طلبات الناشر');
    return jsonDecode(response.body)['data'] as List<dynamic>;
  }

  Future<List<Book>> publisherProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publisher/products'),
      headers: _headers(token),
    );
    if (response.statusCode >= 400) throw Exception('فشل تحميل منتجات الناشر');
    final List<dynamic> data = jsonDecode(response.body)['data'];
    return data.map((e) => Book.fromJson(e)).toList();
  }

  Future<void> publisherCreateProduct(
    String token, {
    required String title,
    required String author,
    required int price,
    required String category,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/publisher/products'),
      headers: _headers(token),
      body: jsonEncode({
        'title': title,
        'author': author,
        'price': price,
        'oldPrice': 0,
        'rating': 0,
        'reviewsCount': 0,
        'category': category,
        'color': '#8A5A44',
        'stock': 20,
        'imageUrl': imageUrl,
      }),
    );
    if (response.statusCode >= 400) throw Exception('فشل إضافة المنتج');
  }
}
