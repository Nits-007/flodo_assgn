import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_functions.dart';
import 'home_screen.dart';
import 'create_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const FlodoApp(),
    ),
  );
}

class FlodoApp extends StatelessWidget {
  const FlodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flodo Tasks',
      debugShowCheckedModeBanner: false,
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    primary: const Color(0xFF6366F1),
    secondary: const Color(0xFF9333EA),
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
    color: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
  ),
),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/create': (context) => const TaskCreationScreen(), 
      },
    );
  }
}