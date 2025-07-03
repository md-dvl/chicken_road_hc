import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScoreBoardScreen extends StatelessWidget {
  const ScoreBoardScreen({super.key});

  // Color palette matching the game
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color panelGrey = Color(0xFF0F3460);
  static const Color greyMultiplier = Color(0xFF0F3460);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF6B35);

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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Best Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [panelGrey, greyMultiplier],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: goldColor.withOpacity(0.3),
                    width: 2,
                  ),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: goldColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.star_fill,
                        color: darkBackground,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'BEST SCORE',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '0',
                      style: TextStyle(
                        color: whiteText,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Statistics section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        panelGrey.withOpacity(0.8),
                        greyMultiplier.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: goldColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STATISTICS',
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatRow('Games Played', '0'),
                      _buildStatRow('Total Score', '0'),
                      _buildStatRow('Best Multiplier', '0.0x'),
                      _buildStatRow('Total Earnings', '\$0.00'),
                      const Spacer(),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: panelGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Statistics will be implemented soon!\nStart playing to see your progress here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: whiteText,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: whiteText, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: goldColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
