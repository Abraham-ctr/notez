import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:notez/providers/task_provider.dart';
import 'package:notez/providers/theme_provider.dart';
import 'package:notez/screens/home_screen.dart';
import 'package:notez/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDqVGj0m9tjIqZ9mVnTTq2TaYuc0hHyl1g",
      authDomain: "notez-4e7a2.firebaseapp.com",
      projectId: "notez-4e7a2",
      storageBucket: "notez-4e7a2.firebasestorage.app",
      messagingSenderId: "720821503575",
      appId: "1:720821503575:web:595e726766c07325268512",
    ),
  );
  runApp(const NotezApp());
}

class NotezApp extends StatelessWidget {
  const NotezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Notez',
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.backgroundLight,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary,
              ),
              cardColor: AppColors.cardLight,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textDark),
                bodyMedium: TextStyle(color: AppColors.grey),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.cardDark,
                foregroundColor: Colors.white,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.accent,
              ),
              cardColor: AppColors.cardDark,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: AppColors.textLight),
                bodyMedium: TextStyle(color: AppColors.grey),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
