import 'package:flutter/material.dart';
import 'package:plumlogix_poc/splash.dart';

void main() {
  runApp(const POCApp());
}

class POCApp extends StatelessWidget {
  const POCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlumLogix POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
