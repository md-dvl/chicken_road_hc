import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ChickenRoadApp());
}

class ChickenRoadApp extends StatelessWidget {
  const ChickenRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Chicken Road Ultimate',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
