import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String name, String email, String password, {String role = 'customer'}) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
      'balance': 0,
      'favorites': [], 
      'createdAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>> fetchProfile(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchBooks() async {
    QuerySnapshot snapshot = await _db.collection('books').where('status', isEqualTo: 'approved').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  Future<void> toggleFavorite(String uid, String bookId) async {
    try {
      DocumentReference userRef = _db.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        await userRef.set({
          'favorites': [bookId]
        }, SetOptions(merge: true));
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>?;
      List favorites = data?['favorites'] ?? [];

      if (favorites.contains(bookId)) {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([bookId])
        });
      } else {
        await userRef.update({
          'favorites': FieldValue.arrayUnion([bookId])
        });
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> updateCart(String uid, String bookId, int quantity) async {
    await _db.collection('users').doc(uid).collection('cart').doc(bookId).set({
      'bookId': bookId,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromCart(String uid, String bookId) async {
    await _db.collection('users').doc(uid).collection('cart').doc(bookId).delete();
  }

  Future<List<Map<String, dynamic>>> fetchCart(String uid) async {
    QuerySnapshot snapshot = await _db.collection('users').doc(uid).collection('cart').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> createProduct(String publisherId, Map<String, dynamic> bookData) async {
    await _db.collection('books').add({
      ...bookData,
      'publisherId': publisherId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchPublisherProducts(String publisherId) async {
    QuerySnapshot snapshot = await _db.collection('books').where('publisherId', isEqualTo: publisherId).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPendingProducts() async {
    QuerySnapshot snapshot = await _db.collection('books').where('status', isEqualTo: 'pending').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  Future<void> updateProductStatus(String bookId, String status) async {
    await _db.collection('books').doc(bookId).update({'status': status});
  }

  Future<void> seedDatabase() async {
    final booksRef = _db.collection('books');
    final snapshot = await booksRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; 

    final initialBooks = [
      {
        'title': 'ألف ليلة وليلة',
        'author': 'مجهول',
        'price': 120,
        'category': 'روايات',
        'color': '#9B5A24',
        'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=800&q=80',
        'stock': 18,
        'publisherId': 'p1',
        'status': 'approved',
        'rating': 4.8,
      },
      {
        'title': 'العادات الذرية',
        'author': 'جيمس كلير',
        'price': 89,
        'category': 'تنمية',
        'color': '#2EA3DE',
        'imageUrl': 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=800&q=80',
        'stock': 22,
        'publisherId': 'p1',
        'status': 'approved',
        'rating': 4.9,
      },
      {
        'title': 'فن اللامبالاة',
        'author': 'مارك مانسون',
        'price': 75,
        'category': 'تنمية',
        'color': '#FF7A1A',
        'imageUrl': 'https://images.unsplash.com/photo-1473755504818-b72b6dfdc226?auto=format&fit=crop&w=800&q=80',
        'stock': 14,
        'publisherId': 'p1',
        'status': 'approved',
        'rating': 4.5,
      },
      {
        'title': 'مقدمة ابن خلدون',
        'author': 'ابن خلدون',
        'price': 150,
        'category': 'تاريخ',
        'color': '#4A3B22',
        'imageUrl': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=800&q=80',
        'stock': 5,
        'publisherId': 'p1',
        'status': 'approved',
        'rating': 5.0,
      },
      {
        'title': 'لأنك الله',
        'author': 'علي الفيفي',
        'price': 65,
        'category': 'ديني',
        'color': '#336633',
        'imageUrl': 'https://images.unsplash.com/photo-1585779034823-7e9ac8faec70?auto=format&fit=crop&w=800&q=80',
        'stock': 30,
        'publisherId': 'p1',
        'status': 'approved',
        'rating': 4.7,
      },
      {
        'title': 'قوة الآن',
        'author': 'إيكهارت تول',
        'price': 95,
        'category': 'تنمية',
        'color': '#E6B800',
        'imageUrl': 'https://images.unsplash.com/photo-1541963463532-d68292c34b19?auto=format&fit=crop&w=800&q=80',
        'stock': 12,
        'publisherId': 'p1',
        'status': 'approved',
        'rating': 4.6,
      }
    ];

    for (var book in initialBooks) {
      await booksRef.add(book);
    }
  }
}
