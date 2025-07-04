import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScoreBoardScreen extends StatefulWidget {
  const ScoreBoardScreen({super.key});

  @override
  State<ScoreBoardScreen> createState() => _ScoreBoardScreenState();
}

class _ScoreBoardScreenState extends State<ScoreBoardScreen> {
  int _selectedTab = 0;

  // Color palette matching the game
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color panelGrey = Color(0xFF0F3460);
  static const Color greyMultiplier = Color(0xFF0F3460);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color redColor = Color(0xFFFF4757);

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockGames = [
    {
      'score': 125,
      'earnings': 45.50,
      'maxMultiplier': 8.2,
      'difficulty': 'Hard',
      'bet': 5,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'stepsCompleted': 25,
      'cashedOut': true,
    },
    {
      'score': 89,
      'earnings': 0.0,
      'maxMultiplier': 3.4,
      'difficulty': 'Medium',
      'bet': 2,
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'stepsCompleted': 18,
      'cashedOut': false,
    },
    {
      'score': 234,
      'earnings': 125.75,
      'maxMultiplier': 15.5,
      'difficulty': 'Easy',
      'bet': 1,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'stepsCompleted': 47,
      'cashedOut': true,
    },
    {
      'score': 67,
      'earnings': 18.40,
      'maxMultiplier': 4.6,
      'difficulty': 'Medium',
      'bet': 2,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'stepsCompleted': 13,
      'cashedOut': true,
    },
    {
      'score': 156,
      'earnings': 0.0,
      'maxMultiplier': 6.8,
      'difficulty': 'Hard',
      'bet': 5,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'stepsCompleted': 31,
      'cashedOut': false,
    },
  ];

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'First Steps',
      'description': 'Play your first game',
      'icon': '🐣',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'title': 'Getting Started',
      'description': 'Reach score of 10',
      'icon': '🎯',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(days: 4)),
    },
    {
      'title': 'Road Runner',
      'description': 'Reach score of 50',
      'icon': '🏃',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'title': 'Century Club',
      'description': 'Reach score of 100',
      'icon': '💯',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'title': 'Risk Taker',
      'description': 'Reach 5x multiplier',
      'icon': '🎲',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'title': 'High Roller',
      'description': 'Reach 10x multiplier',
      'icon': '🚀',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      'title': 'Smart Player',
      'description': 'Cash out with \$100+',
      'icon': '💰',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      'title': 'Survivor',
      'description': 'Complete 20 steps in one game',
      'icon': '🛡️',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'title': 'Hardcore Player',
      'description': 'Win a game on Hard difficulty',
      'icon': '🔥',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'title': 'Lucky Streak',
      'description': 'Cash out successfully 5 times',
      'icon': '🍀',
      'unlocked': false,
      'unlockedDate': null,
    },
    {
      'title': 'Big Spender',
      'description': 'Play with \$5 bet',
      'icon': '💎',
      'unlocked': true,
      'unlockedDate': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'title': 'Veteran',
      'description': 'Play 50 games',
      'icon': '🏆',
      'unlocked': false,
      'unlockedDate': null,
    },
  ];

  // Calculated stats from mock data
  int get _bestScore =>
      _mockGames.map((g) => g['score'] as int).reduce((a, b) => a > b ? a : b);
  int get _totalGames => _mockGames.length;
  double get _totalEarnings =>
      _mockGames.fold(0.0, (sum, g) => sum + (g['earnings'] as double));
  double get _bestMultiplier => _mockGames
      .map((g) => g['maxMultiplier'] as double)
      .reduce((a, b) => a > b ? a : b);
  int get _successfulCashouts =>
      _mockGames.where((g) => g['cashedOut'] as bool).length;
  int get _unlockedAchievements =>
      _achievements.where((a) => a['unlocked'] as bool).length;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: darkBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: panelGrey,
        middle: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [goldColor, accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'SCORE BOARD',
            style: TextStyle(
              color: darkBackground,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatsOverview(),
              const SizedBox(height: 20),
              _buildTabSelector(),
              const SizedBox(height: 20),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [panelGrey, greyMultiplier],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Best Score',
                _bestScore.toString(),
                CupertinoIcons.star_fill,
              ),
              _buildStatItem(
                'Total Games',
                _totalGames.toString(),
                CupertinoIcons.game_controller,
              ),
              _buildStatItem(
                'Achievements',
                '$_unlockedAchievements/${_achievements.length}',
                CupertinoIcons.rosette,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Best Multiplier',
                '${_bestMultiplier.toStringAsFixed(1)}x',
                CupertinoIcons.chart_bar_alt_fill,
              ),
              _buildStatItem(
                'Total Earnings',
                '\$${_totalEarnings.toStringAsFixed(2)}',
                CupertinoIcons.money_dollar,
              ),
              _buildStatItem(
                'Cash Outs',
                _successfulCashouts.toString(),
                CupertinoIcons.checkmark_circle_fill,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: goldColor, shape: BoxShape.circle),
            child: Icon(icon, color: darkBackground, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: whiteText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: goldColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return CupertinoSlidingSegmentedControl<int>(
      backgroundColor: panelGrey,
      thumbColor: goldColor,
      padding: const EdgeInsets.all(4),
      groupValue: _selectedTab,
      onValueChanged: (value) {
        setState(() {
          _selectedTab = value!;
        });
      },
      children: {
        0: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Recent Games',
            style: TextStyle(
              color: _selectedTab == 0 ? darkBackground : whiteText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        1: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Achievements',
            style: TextStyle(
              color: _selectedTab == 1 ? darkBackground : whiteText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      },
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) {
      return _buildRecentGames();
    } else {
      return _buildAchievements();
    }
  }

  Widget _buildRecentGames() {
    return ListView.builder(
      itemCount: _mockGames.length,
      itemBuilder: (context, index) {
        final game = _mockGames[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                panelGrey.withOpacity(0.8),
                greyMultiplier.withOpacity(0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: game['cashedOut']
                  ? goldColor.withOpacity(0.5)
                  : redColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: game['cashedOut'] ? goldColor : redColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          game['cashedOut']
                              ? CupertinoIcons.checkmark
                              : CupertinoIcons.xmark,
                          color: darkBackground,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        game['cashedOut'] ? 'CASHED OUT' : 'CRASHED',
                        style: TextStyle(
                          color: game['cashedOut'] ? goldColor : redColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${game['date'].day}/${game['date'].month} ${game['date'].hour}:${game['date'].minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: whiteText, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGameStatItem('Score', game['score'].toString()),
                  _buildGameStatItem('Bet', '\$${game['bet']}'),
                  _buildGameStatItem(
                    'Max Multiplier',
                    '${game['maxMultiplier'].toStringAsFixed(1)}x',
                  ),
                  _buildGameStatItem(
                    'Earnings',
                    '\$${game['earnings'].toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Difficulty: ${game['difficulty']}',
                    style: const TextStyle(color: whiteText, fontSize: 13),
                  ),
                  Text(
                    'Steps: ${game['stepsCompleted']}',
                    style: const TextStyle(color: whiteText, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: whiteText, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: goldColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: achievement['unlocked']
                  ? [goldColor.withOpacity(0.2), accentOrange.withOpacity(0.2)]
                  : [
                      panelGrey.withOpacity(0.5),
                      greyMultiplier.withOpacity(0.5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: achievement['unlocked']
                  ? goldColor.withOpacity(0.5)
                  : whiteText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(achievement['icon'], style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                achievement['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: achievement['unlocked']
                      ? goldColor
                      : whiteText.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                achievement['description'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: achievement['unlocked']
                      ? whiteText
                      : whiteText.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              if (achievement['unlocked'] &&
                  achievement['unlockedDate'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Unlocked: ${achievement['unlockedDate'].day}/${achievement['unlockedDate'].month}',
                    style: TextStyle(
                      color: goldColor.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
