import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/chicken_road_screen.dart';

void main() {
  runApp(const ChickenRoadApp());
}

class ChickenRoadApp extends StatelessWidget {
  const ChickenRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Chicken Road Ultimate',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemYellow,
        brightness: Brightness.light,
      ),
      home: ChickenRoadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
