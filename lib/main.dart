import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MoneyGuaApp());
}

class MoneyGuaApp extends StatelessWidget {
  const MoneyGuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '金钱卦',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFA8D8B9),
          surface: Color(0xFF1E1E1E),
        ),
        fontFamily: 'Roboto', // Or a Chinese font if available
      ),
      home: const HomePage(),
    );
  }
}