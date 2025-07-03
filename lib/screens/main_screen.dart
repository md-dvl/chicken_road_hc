import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chicken_road_screen.dart';
import 'score_board_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Color palette matching the game
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color panelGrey = Color(0xFF0F3460);
  static const Color whiteText = Color(0xFFFFFFFF);

  final List<Widget> _screens = [
    const ChickenRoadScreen(),
    const ScoreBoardScreen(),
    const SettingsScreen(),
  ];

  final List<IconData> _icons = [
    CupertinoIcons.game_controller,
    CupertinoIcons.chart_bar,
    CupertinoIcons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: darkBackground,
      tabBar: CupertinoTabBar(
        backgroundColor: panelGrey,
        activeColor: goldColor,
        inactiveColor: whiteText.withOpacity(0.6),
        border: Border(
          top: BorderSide(color: goldColor.withOpacity(0.3), width: 1),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == 0
                    ? goldColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icons[0]),
            ),
            label: 'Road',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == 1
                    ? goldColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icons[1]),
            ),
            label: 'Scores',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == 2
                    ? goldColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icons[2]),
            ),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _screens[index];
          },
        );
      },
    );
  }
}
