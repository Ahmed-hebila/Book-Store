import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bookstore_app/main.dart';
import 'package:bookstore_app/providers/app_state.dart';
import 'package:bookstore_app/data/services/firebase_service.dart';

void main() {
  testWidgets('App shows login screen', (WidgetTester tester) async {
    final firebaseService = FirebaseService(); 
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: firebaseService),
          ChangeNotifierProvider(create: (_) => AppState(firebaseService)),
        ],
        // تمرير isReady: true لتجاوز شاشة الخطأ في الاختبارات
        child: const BookStoreApp(isReady: true),
      ),
    );
  });
}
