import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chicken_road_game.dart';

class ChickenRoadScreen extends StatefulWidget {
  const ChickenRoadScreen({super.key});

  @override
  State<ChickenRoadScreen> createState() => _ChickenRoadScreenState();
}

class _ChickenRoadScreenState extends State<ChickenRoadScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _obstaclesAnimationController;
  late AnimationController _chickenAnimationController;

  // Game model - single source of truth for all game state and logic
  late ChickenRoadGame game;

  // Multiplier progression (levels of achievement)
  List<double> multiplierLevels = [
    1.0,
    1.2,
    1.4,
    1.6,
    1.8,
    2.0,
    2.3,
    2.6,
    3.0,
    3.5,
    4.0,
    4.5,
    5.0,
    6.0,
    7.0,
    8.0,
    10.0,
    12.0,
    15.0,
    20.0,
  ];

  // Game color palette
  static const Color darkBackground = Color(0xFF2D2D2D);
  static const Color roadGrey = Color(0xFF4A4A4A);
  static const Color goldColor = Color(0xFFF1C40F);
  static const Color greenButton = Color(0xFF27AE60);
  static const Color redColor = Color(0xFFE74C3C);
  static const Color greyMultiplier = Color(0xFF7F8C8D);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color panelGrey = Color(0xFF3A3A3A);

  @override
  void initState() {
    super.initState();

    // Initialize game model
    game = ChickenRoadGame();

    // Set up UI update callbacks
    game.onStateChanged = () {
      if (mounted) {
        setState(() {});
      }
    };

    game.onShowMessage = (String message) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    };

    // Initialize animation controllers
    _obstaclesAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _chickenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _obstaclesAnimationController.dispose();
    _chickenAnimationController.dispose();
    game.dispose();
    super.dispose();
  }

  void _startGame() {
    game.startGame();
  }

  void _moveChickenForward() {
    game.moveChickenForward();
  }

  void _handleMainButton() {
    if (game.isGameActive) {
      // Game is active, move chicken forward
      _moveChickenForward();
    } else {
      // Game is not active, start the game
      _startGame();
    }
  }

  void _moveChickenUp() {
    game.moveChickenUp();
  }

  void _moveChickenDown() {
    game.moveChickenDown();
  }

  void _cashOut() {
    game.cashOut();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: darkBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildGameInfoBar(),
            Expanded(child: _buildGameGrid()),
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CHICKEN ROAD',
            style: TextStyle(
              color: whiteText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.question_circle,
                  color: whiteText,
                ),
                onPressed: () => _showHowToPlay(),
              ),
              const SizedBox(width: 8),
              const Text('How to play?', style: TextStyle(color: whiteText)),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: panelGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.money_dollar,
                      color: goldColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${game.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: whiteText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.person_circle, color: whiteText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score and lives
          Row(
            children: [
              const Icon(CupertinoIcons.star_fill, color: goldColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Score: ${game.score}',
                style: const TextStyle(color: whiteText, fontSize: 14),
              ),
              const SizedBox(width: 12),
              Row(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      CupertinoIcons.heart_fill,
                      color: index < game.chickenLives ? redColor : Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Current multiplier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: greyMultiplier,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${game.currentMultiplier.toStringAsFixed(2)}x',
              style: const TextStyle(
                color: whiteText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Game status
          if (game.isPaused)
            const Text(
              'PAUSED',
              style: TextStyle(color: goldColor, fontSize: 14),
            ),
          if (game.isGameOver)
            const Text(
              'GAME OVER',
              style: TextStyle(color: redColor, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < -250) {
          _moveChickenUp(); // Swipe up to move up
        } else if (details.velocity.pixelsPerSecond.dy > 250) {
          _moveChickenDown(); // Swipe down to move down
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: roadGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            _buildRoadBackground(),
            _buildRoadLines(),
            ..._buildManholes(),
            ..._buildBarriers(),
            ..._buildObstacles(),
            _buildChicken(),
            ..._buildFloatingTexts(),
            if (game.showCollisionAnimation) _buildCollisionEffect(),
            if (game.showCashOutAnimation) _buildCashOutEffect(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadBackground() {
    return Container(
      decoration: BoxDecoration(
        color: roadGrey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildRoadLines() {
    return CustomPaint(
      size: Size.infinite,
      painter: RoadLinesPainter(0.0), // Static road lines without animation
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: panelGrey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bet and difficulty selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Bet options
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: ChickenRoadGame.betOptions
                      .map(
                        (bet) => GestureDetector(
                          onTap: () => setState(() => game.selectedBet = bet),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: game.selectedBet == bet
                                  ? goldColor
                                  : greyMultiplier,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$$bet',
                              style: const TextStyle(
                                color: whiteText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              // Difficulty selector
              Flexible(
                child: Material(
                  color: Colors.transparent,
                  child: Localizations(
                    locale: const Locale('en', 'US'),
                    delegates: const [
                      DefaultMaterialLocalizations.delegate,
                      DefaultWidgetsLocalizations.delegate,
                    ],
                    child: DropdownButton<String>(
                      value: game.selectedDifficulty,
                      dropdownColor: panelGrey,
                      style: const TextStyle(color: whiteText),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            game.selectedDifficulty = newValue;
                          });
                        }
                      },
                      items: ChickenRoadGame.difficulties
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  color: greenButton,
                  onPressed: _handleMainButton,
                  child: Text(
                    game.isGameActive
                        ? 'GO'
                        : (game.isGameOver ? 'RESTART' : 'START'),
                    style: const TextStyle(
                      color: whiteText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CupertinoButton(
                  color: goldColor,
                  onPressed: game.isGameActive ? _cashOut : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'CASH OUT',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${game.cashOutAmount.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHowToPlay() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('How to Play'),
        content: const Text(
          '1. Select your bet amount and difficulty.\n2. Press START to begin.\n3. Swipe up/down to move the chicken between lanes.\n4. Avoid cars moving down the road and collect coins.\n5. Press GO to move the chicken to the right.\n6. Press CASH OUT at any time to take your winnings before you crash!\n\nThe game is infinite - survive as long as possible!',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Got it!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildObstacles() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;

    return game.obstacles.map((obstacle) {
      // Cars move vertically down the lanes
      return Positioned(
        left: obstacle.lane * screenWidth - 20, // Lane position (horizontal)
        top: obstacle.verticalPosition * screenHeight - 20, // Vertical movement
        child: SizedBox(
          width: 40,
          height: 60, // Make cars taller (like real cars)
          child: Image.asset(
            'assets/car${obstacle.type + 1}.png', // Use car1.png, car2.png, car3.png, car4.png
            width: 40,
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image not found
              return Container(
                decoration: BoxDecoration(
                  color: redColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  Widget _buildChicken() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;

    // Chicken moves horizontally (left to right) and between lanes (up/down)
    return Positioned(
      left:
          game.chickenHorizontalPos * screenWidth -
          25, // Horizontal movement (left to right)
      top:
          0.5 * screenHeight - 25, // Same positioning as manholes (center line)
      child: SizedBox(
        width: 50,
        height: 50,
        child: CustomPaint(painter: ChickenPainter()),
      ),
    );
  }

  Widget _buildCollisionEffect() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: redColor.withOpacity(0.7),
        ),
        child: const Center(
          child: Text(
            'CRASH!',
            style: TextStyle(
              color: whiteText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashOutEffect() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: goldColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Text(
          '\$${game.cashOutAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildManholes() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;

    return game.manholes.map((manhole) {
      // Manholes are positioned horizontally at centers between lane dividers
      // Lane centers: 0.3, 0.5, 0.7, 0.9 (between dashed lines, excluding first lane)
      List<double> laneCenters = [0.3, 0.5, 0.7, 0.9];
      int manholeIndex = game.manholes.indexOf(manhole);

      // Get horizontal position for this manhole (center between lane dividers)
      double horizontalLanePos = laneCenters[manholeIndex % laneCenters.length];

      return Positioned(
        left:
            horizontalLanePos * screenWidth -
            20, // Center between lane dividers
        top:
            0.5 * screenHeight -
            20, // All manholes on same horizontal line (center)
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Manhole/Coin
            Container(
              width: 40,
              height: 40,
              child: manhole.isTransformedToCoin
                  ? Image.asset(
                      'assets/coin.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: goldColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/manhole.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.circle_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Multiplier text overlay (only show if not transformed to coin)
            if (!manhole.isTransformedToCoin)
              Positioned(
                top: -5,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${manhole.multiplier.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildBarriers() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;

    return game.barriers.map((barrier) {
      return Positioned(
        left: barrier.horizontalPos * screenWidth - 20,
        top: 0.5 * screenHeight + (screenHeight * 0.1) - 50, // 50 pixels above manholes
        child: Container(
          width: 40,
          height: 40,
          child: Image.asset(
            'assets/barrier.png',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFloatingTexts() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return [];
    final size = renderBox.size;

    return game.floatingTexts.map((ft) {
      return Positioned(
        left: ft.lane * (size.width - 40),
        top: (ft.position * (size.height * 0.6)) - (ft.animationProgress * 50),
        child: Opacity(
          opacity: 1.0 - ft.animationProgress,
          child: Text(
            ft.text,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

// Custom painter for road lines
class RoadLinesPainter extends CustomPainter {
  final double animation;

  RoadLinesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final dashHeight = 30.0;
    final dashSpace = 15.0;
    final totalHeight = dashHeight + dashSpace;
    final offset = animation * totalHeight;

    // Draw vertical lane dividers
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      for (
        double y = -offset % totalHeight;
        y < size.height + totalHeight;
        y += totalHeight
      ) {
        canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), paint);
      }
    }

    // Draw top and bottom barriers
    final sideBarrierPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 5;

    // Top barrier
    canvas.drawLine(
      const Offset(0, 10),
      Offset(size.width, 10),
      sideBarrierPaint,
    );

    // Bottom barrier
    canvas.drawLine(
      Offset(0, size.height - 10),
      Offset(size.width, size.height - 10),
      sideBarrierPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChickenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.yellow;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.9,
      ),
      bodyPaint,
    );

    final beakPaint = Paint()..color = Colors.orange;
    final beakPath = Path();
    beakPath.moveTo(size.width * 0.8, size.height * 0.45);
    beakPath.lineTo(size.width, size.height * 0.5);
    beakPath.lineTo(size.width * 0.8, size.height * 0.55);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 3, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
