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
  late AnimationController _multiplierContainerAnimationController;

  // Game model - single source of truth for all game state and logic
  late ChickenRoadGame game;

  // UI state for multiplier display
  bool showMultiplierContainer = false; // Start hidden since multiplier is 0

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

  // Game color palette - bright and contrasting
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color roadGrey = Color(0xFF16213E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color greenButton = Color(0xFF00FF87);
  static const Color redColor = Color(0xFFFF4757);
  static const Color greyMultiplier = Color(0xFF0F3460);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color panelGrey = Color(0xFF0F3460);
  static const Color accentBlue = Color(0xFF2ECC71);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentOrange = Color(0xFFFF6B35);

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
    );

    _multiplierContainerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _obstaclesAnimationController.dispose();
    _chickenAnimationController.dispose();
    _multiplierContainerAnimationController.dispose();
    game.dispose();
    super.dispose();
  }

  void _startGame() {
    game.startGame();
    // Hide multiplier container when starting (since currentMultiplier is 0)
    setState(() {
      showMultiplierContainer = false;
    });
    _multiplierContainerAnimationController.reverse();
  }

  void _moveChickenForward() {
    // Add chicken animation
    _chickenAnimationController.forward().then((_) {
      _chickenAnimationController.reverse();
    });

    // Hide multiplier container during movement
    _multiplierContainerAnimationController.reverse();
    setState(() {
      showMultiplierContainer = false;
    });

    game.moveChickenForward();

    // Show multiplier container again after movement with animation (only if multiplier > 0)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && game.currentMultiplier > 0) {
        setState(() {
          showMultiplierContainer = true;
        });
        _multiplierContainerAnimationController.forward();
      }
    });
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
    _chickenAnimationController.forward().then((_) {
      _chickenAnimationController.reverse();
    });
    game.moveChickenUp();
  }

  void _moveChickenDown() {
    _chickenAnimationController.forward().then((_) {
      _chickenAnimationController.reverse();
    });
    game.moveChickenDown();
  }

  void _cashOut() {
    game.cashOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
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
      decoration: BoxDecoration(color: darkBackground),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [goldColor, accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: goldColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Text(
            'CHICKEN ROAD ULTIMATE',
            style: TextStyle(
              color: darkBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [panelGrey.withOpacity(0.8), greyMultiplier.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score and lives (closer together)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: goldColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.star_fill,
                  color: darkBackground,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Score: ${game.score}',
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: index < game.chickenLives
                          ? redColor
                          : Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                      boxShadow: index < game.chickenLives
                          ? [
                              BoxShadow(
                                color: redColor.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      CupertinoIcons.heart_fill,
                      color: index < game.chickenLives
                          ? whiteText
                          : Colors.grey,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Balance display (moved to the right)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goldColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.money_dollar,
                  color: darkBackground,
                  size: 12,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${game.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Transform.translate(
            offset: Offset(
              game.slideOffset * MediaQuery.of(context).size.width,
              0,
            ),
            child: Stack(
              children: [
                _buildRoadBackground(),
                _buildRoadLines(),
                ..._buildManholes(),
                ..._buildBarriers(),
                ..._buildObstacles(),
                _buildChicken(),
                if (showMultiplierContainer && game.currentMultiplier > 0)
                  _buildChickenMultiplierContainer(),
                ..._buildFloatingTexts(),
                if (game.showCollisionAnimation) _buildCollisionEffect(),
                if (game.showCashOutAnimation) _buildCashOutEffect(),
                if (game.isSlideAnimating) _buildLevelTransitionOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoadBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [roadGrey, panelGrey, roadGrey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentBlue.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [panelGrey, darkBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: goldColor.withOpacity(0.3), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
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
                              gradient: game.selectedBet == bet
                                  ? LinearGradient(
                                      colors: [goldColor, accentOrange],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [greyMultiplier, panelGrey],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: game.selectedBet == bet
                                    ? goldColor
                                    : greyMultiplier.withOpacity(0.5),
                                width: 1,
                              ),
                              boxShadow: game.selectedBet == bet
                                  ? [
                                      BoxShadow(
                                        color: goldColor.withOpacity(0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              '\$$bet',
                              style: TextStyle(
                                color: game.selectedBet == bet
                                    ? darkBackground
                                    : whiteText,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Difficulty:',
                      style: TextStyle(
                        color: whiteText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: ChickenRoadGame.difficulties
                          .map(
                            (difficulty) => Opacity(
                              opacity: game.isGameActive
                                  ? 0.5
                                  : 1.0, // Dim when game is active
                              child: GestureDetector(
                                onTap: () {
                                  if (!game.isGameActive) {
                                    game.updateDifficulty(difficulty);
                                    setState(() {}); // Refresh UI
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient:
                                        game.selectedDifficulty == difficulty
                                        ? LinearGradient(
                                            colors: [accentPurple, accentBlue],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : LinearGradient(
                                            colors: [greyMultiplier, panelGrey],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          game.selectedDifficulty == difficulty
                                          ? accentPurple
                                          : greyMultiplier.withOpacity(0.5),
                                      width: 1,
                                    ),
                                    boxShadow:
                                        game.selectedDifficulty == difficulty
                                        ? [
                                            BoxShadow(
                                              color: accentPurple.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    difficulty,
                                    style: TextStyle(
                                      color: whiteText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons and How to play
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56.0, // Фиксированная высота
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [greenButton, accentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: greenButton.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: _handleMainButton,
                    child: Center(
                      child: Text(
                        game.isGameActive
                            ? 'GO'
                            : (game.isGameOver ? 'RESTART' : 'START'),
                        style: const TextStyle(
                          color: whiteText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 56.0, // Фиксированная высота
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [goldColor, accentOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: game.isGameActive ? _cashOut : null,
                    child: Center(
                      child: Text(
                        'CASH OUT\n\$${game.cashOutAmount.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: darkBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // How to play button
          Center(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentPurple.withOpacity(0.7), panelGrey],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentPurple.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      CupertinoIcons.question_circle,
                      color: whiteText,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'How to play?',
                      style: TextStyle(color: whiteText, fontSize: 14),
                    ),
                  ],
                ),
                onPressed: () => _showHowToPlay(),
              ),
            ),
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
          '1. Select your award amount and difficulty.\n2. Press START to begin.\n3. Avoid cars moving down the road and collect coins.\n4. Press GO to move the chicken to the right.\n5. Press CASH OUT at any time to take your winnings before you crash!\n\nThe game is infinite - survive as long as possible!',
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
      // Lane positions: 0.1, 0.3, 0.5, 0.7, 0.9 correspond to centers between dashed lines
      return Positioned(
        left: obstacle.lane * screenWidth - 20, // Center cars in lanes
        top: obstacle.verticalPosition * screenHeight - 30,
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

    // Chicken position:
    // - Horizontal (left-right): controlled by chickenHorizontalPos (0.1 to 0.9)
    // - Vertical (lane): controlled by chickenLane (0.1, 0.3, 0.5, 0.7, 0.9)
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: game.chickenHorizontalPos * screenWidth - 25,
      top: game.chickenLane * screenHeight - 25, // Same positioning as cars
      child: AnimatedBuilder(
        animation: _chickenAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale:
                1.0 +
                (0.1 *
                    (_chickenAnimationController.value > 0.5
                        ? 1.0 - _chickenAnimationController.value
                        : _chickenAnimationController.value)),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                'assets/chicken.png',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to custom painter if image not found
                  return CustomPaint(painter: ChickenPainter());
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChickenMultiplierContainer() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: game.chickenHorizontalPos * screenWidth - 35,
      top: game.chickenLane * screenHeight + 35, // 35 pixels below chicken
      child: AnimatedBuilder(
        animation: _multiplierContainerAnimationController,
        builder: (context, child) {
          // Create bounce effect using elastic ease
          final bounceValue = Curves.elasticOut.transform(
            _multiplierContainerAnimationController.value,
          );

          return Transform.scale(
            scale: bounceValue,
            child: AnimatedOpacity(
              opacity: showMultiplierContainer ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goldColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '\$${game.currentMultiplier.toStringAsFixed(1)}', // Show as gold amount with $ symbol
                  style: const TextStyle(
                    color: goldColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
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
          '\$${game.cashOutAmountForAnimation.toStringAsFixed(2)}',
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
    final List<double> laneCenters = [0.3, 0.5, 0.7, 0.9];

    List<Widget> manholeWidgets = [];

    for (int i = 0; i < game.manholes.length; i++) {
      final manhole = game.manholes[i];
      final horizontalLanePos = laneCenters[i % laneCenters.length];

      // Add manhole/coin
      manholeWidgets.add(
        Positioned(
          left: horizontalLanePos * screenWidth - 20,
          top:
              0.5 * screenHeight -
              20, // All manholes on same horizontal line (center)
          child: Container(
            width: 40,
            height: 40,
            child: manhole.isTransforming
                ? AnimatedBuilder(
                    animation: _obstaclesAnimationController,
                    builder: (context, child) {
                      // Animation from manhole to coin (180 degree flip)
                      final progress = manhole.transformProgress;
                      final angle = progress * 3.14159; // 180 degree rotation
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..rotateY(angle),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: progress < 0.5
                              ? Image.asset(
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
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
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
                                )
                              : Image.asset(
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
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
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
                                ),
                        ),
                      );
                    },
                  )
                : manhole.isTransformedToCoin
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
        ),
      );

      // Add multiplier text above manhole (only if not activated and not transformed to coin)
      if (!manhole.isActivated && !manhole.isTransformedToCoin) {
        manholeWidgets.add(
          Positioned(
            left:
                horizontalLanePos * screenWidth - 30, // Slightly wider for text
            top: 0.5 * screenHeight - 50, // 30 pixels above manhole
            child: Container(
              width: 60,
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
        );
      }
    }

    return manholeWidgets;
  }

  List<Widget> _buildBarriers() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;

    return game.barriers.map((barrier) {
      return Positioned(
        left: barrier.horizontalPos * screenWidth - 20,
        top:
            0.5 * screenHeight -
            90, // 70 pixels above manholes (top of manholes)
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
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.warning, color: Colors.black, size: 20),
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
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLevelTransitionOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Colors.transparent,
              darkBackground.withOpacity(0.8),
              darkBackground,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: panelGrey,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: goldColor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward, color: goldColor, size: 40),
                const SizedBox(height: 10),
                Text(
                  'LEVEL ${game.currentLevel}',
                  style: const TextStyle(
                    color: goldColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'NEW MANHOLES AHEAD!',
                  style: TextStyle(color: whiteText, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    // Draw dashed lines for road lanes
    for (int i = 1; i < 5; i++) {
      final x = (size.width / 5) * i;
      for (double y = 0; y < size.height; y += 20) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 10), paint);
      }
    }

    // Draw side barriers
    final sideBarrierPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4;

    // Left barrier
    canvas.drawLine(
      Offset(0, 10),
      Offset(0, size.height - 10),
      sideBarrierPaint,
    );

    // Right barrier
    canvas.drawLine(
      Offset(size.width, 10),
      Offset(size.width, size.height - 10),
      sideBarrierPaint,
    );

    // Top barrier
    canvas.drawLine(Offset(0, 10), Offset(size.width, 10), sideBarrierPaint);

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
