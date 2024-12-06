import 'package:flutter/material.dart';
import 'my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Site Visit',
      theme: ThemeData(
        primaryColor: const Color(0xFF343434),
        colorScheme:
            ThemeData().colorScheme.copyWith(primary: const Color(0xFF343434)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
