import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'data/services/firebase_service.dart';
import 'providers/app_state.dart';
import 'providers/theme_provider.dart';
import 'ui/pages/login_view.dart';
import 'ui/pages/root_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint("Firebase Initialized");
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  final firebaseService = FirebaseService();
  
  if (isFirebaseInitialized) {
    try {
      await firebaseService.seedDatabase();
    } catch (e) {
      debugPrint("Seed error: $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseService>.value(value: firebaseService),
        ChangeNotifierProvider<AppState>(
          create: (context) => AppState(firebaseService),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: BookStoreApp(isReady: isFirebaseInitialized),
    ),
  );
}

class BookStoreApp extends StatelessWidget {
  final bool isReady;
  const BookStoreApp({super.key, required this.isReady});

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 60),
                SizedBox(height: 16),
                Text('فشل الاتصال بـ Firebase', style: TextStyle(fontSize: 18)),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'تأكد من إعداد مشروعك عبر flutterfire configure وتشغيل السيرفر.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Online Bookstore',
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8F6F4),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 32, 201, 128),
              primary: const Color.fromARGB(255, 32, 201, 128),
              brightness: Brightness.light,
            ),
            fontFamily: 'sans-serif',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 32, 201, 128),
              primary: const Color.fromARGB(255, 32, 201, 128),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            fontFamily: 'sans-serif',
          ),
          home: Consumer<AppState>(
            builder: (context, appState, child) {
              return appState.isLoggedIn ? const RootView() : const LoginView();
            },
          ),
        );
      },
    );

  }
}
