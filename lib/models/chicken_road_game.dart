import 'dart:math' as math;
import 'dart:async';

// Game data models
class Obstacle {
  double lane; // Horizontal lane position (0-1)
  double position; // Not used, for compatibility
  int type; // Type of obstacle (0-2)
  double worldX; // Absolute world X position
  double verticalPosition; // Vertical position for cars moving down (0-1)

  Obstacle({
    required this.lane,
    required this.position,
    required this.type,
    required this.worldX,
    required this.verticalPosition,
  });
}

class Coin {
  double lane; // Horizontal lane position (0-1)
  double position; // Not used, for compatibility
  int value; // Coin value
  double worldX; // Absolute world X position
  double verticalPosition; // Vertical position for coins moving down (0-1)

  Coin({
    required this.lane,
    required this.position,
    required this.value,
    required this.worldX,
    required this.verticalPosition,
  });
}

class FloatingText {
  final String text;
  final double position;
  final double lane;
  final int duration;
  int age = 0;

  FloatingText({
    required this.text,
    required this.position,
    required this.lane,
    this.duration = 60, // approx 1 second
  });

  void update() {
    age++;
  }

  bool get isExpired => age >= duration;

  double get animationProgress => age / duration;
}

class Multiplier {
  double value; // Multiplier value
  double position; // Not used, for compatibility
  double worldX; // Absolute world X position

  Multiplier({
    required this.value,
    required this.position,
    required this.worldX,
  });
}

class Manhole {
  double lane; // Horizontal lane position (0-1)
  double worldX; // Absolute world X position
  double verticalPosition; // Vertical position on screen (0-1)
  bool isActivated = false; // Whether chicken has stepped on it
  bool isTransforming = false; // Animation state
  int transformAge = 0; // For animation timing
  static const int transformDuration = 30; // Animation frames

  Manhole({
    required this.lane,
    required this.worldX,
    required this.verticalPosition,
  });

  void startTransformation() {
    isActivated = true;
    isTransforming = true;
    transformAge = 0;
  }

  void updateTransformation() {
    if (isTransforming) {
      transformAge++;
      if (transformAge >= transformDuration) {
        isTransforming = false;
      }
    }
  }

  double get transformProgress =>
      isTransforming ? transformAge / transformDuration : 1.0;
}

// Game state and logic controller
class ChickenRoadGame {
  // Game state
  bool isGameActive = false;
  bool isGameOver = false;
  bool isPaused = false;
  double currentMultiplier = 1.0;
  int selectedBet = 2;
  String selectedDifficulty = 'Medium';
  double cashOutAmount = 0.0;
  double balance = 999.96;
  int coinsCounted = 0;
  int score = 0;

  // Chicken properties
  double chickenLane = 0.5; // Vertical lane position (0.0 to 1.0)
  bool isChickenJumping = false;
  int chickenLives = 3; // Number of lives
  double chickenWorldX =
      0.0; // Absolute world X position (increases as chicken moves)
  double chickenHorizontalPos =
      0.1; // Horizontal position on screen (0.0 to 1.0)

  // Game scrolling
  double backgroundOffset = 0.0;
  double gameSpeed = 1.0;

  // Game objects
  List<Obstacle> obstacles = [];
  List<Coin> coins = [];
  List<Multiplier> visibleMultipliers = [];
  List<FloatingText> floatingTexts = [];
  List<Manhole> manholes = []; // Track manholes separately

  // Visual feedback flags
  bool showCashOutAnimation = false;
  bool showCollisionAnimation = false;
  bool showCoinCollectionAnimation = false;

  // Timer for game loop
  Timer? _gameTimer;

  // Callbacks for UI updates
  Function()? onStateChanged;
  Function(String)? onShowMessage;

  // Difficulty settings
  static const Map<String, Map<String, dynamic>> difficultySettings = {
    'Easy': {
      'obstacleFrequency': 0.7,
      'gameSpeed': 0.8,
      'multiplierRate': 0.05,
      'lives': 3,
    },
    'Medium': {
      'obstacleFrequency': 1.0,
      'gameSpeed': 1.0,
      'multiplierRate': 0.08,
      'lives': 2,
    },
    'Hard': {
      'obstacleFrequency': 1.3,
      'gameSpeed': 1.2,
      'multiplierRate': 0.12,
      'lives': 1,
    },
    'Hardcore': {
      'obstacleFrequency': 1.5,
      'gameSpeed': 1.5,
      'multiplierRate': 0.18,
      'lives': 1,
    },
  };

  // Game data
  static const List<int> betOptions = [1, 2, 5, 10];
  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
    'Hardcore',
  ];

  // Multiplier progression (levels of achievement)
  static const List<double> multiplierLevels = [
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

  // Initialize the game
  void resetGame() {
    isGameActive = false;
    isGameOver = false;
    isPaused = false;
    chickenLane = 0.5; // Start at center lane (middle)
    chickenWorldX = 0.0;
    chickenHorizontalPos = 0.1; // Start at left side
    backgroundOffset = 0.0;
    currentMultiplier = 1.0;
    cashOutAmount = selectedBet.toDouble();
    gameSpeed = difficultySettings[selectedDifficulty]!['gameSpeed'];
    chickenLives = difficultySettings[selectedDifficulty]!['lives'];
    obstacles.clear();
    coins.clear();
    visibleMultipliers.clear();
    floatingTexts.clear();
    manholes.clear(); // Clear manholes

    // Generate initial manholes on all lanes
    for (int row = 0; row < 3; row++) {
      for (int lane = 0; lane < 5; lane++) {
        final lanePosition = lane / 4.0; // 5 lanes: 0, 0.25, 0.5, 0.75, 1.0
        manholes.add(
          Manhole(
            lane: lanePosition,
            worldX: chickenWorldX + 2.0 + (row * 2.0), // Spaced every 2 units
            verticalPosition: lanePosition,
          ),
        );
      }
    }

    score = 0;
    coinsCounted = 0;
    showCashOutAnimation = false;
    showCollisionAnimation = false;
    showCoinCollectionAnimation = false;
    _notifyStateChanged();
  }

  // Start the game
  bool startGame() {
    if (isGameOver) {
      resetGame();
    }

    if (!isGameActive) {
      // Check if player has enough balance
      if (balance >= selectedBet) {
        isGameActive = true;
        balance -= selectedBet;
        cashOutAmount = selectedBet.toDouble();
        _startGameLoop();
        _notifyStateChanged();
        return true;
      } else {
        // Insufficient funds
        onShowMessage?.call("Insufficient funds!");
        return false;
      }
    } else {
      // Move chicken forward manually when already active
      moveChickenForward();
      return true;
    }
  }

  // Move chicken forward (rightward)
  void moveChickenForward() {
    if (isGameActive && !isPaused) {
      chickenHorizontalPos += 0.15; // Move chicken to the right
      if (chickenHorizontalPos > 0.9) {
        chickenHorizontalPos = 0.9; // Don't go off screen
      }
      chickenWorldX +=
          0.2; // Also update world position for multiplier calculation
      _notifyStateChanged();
    }
  }

  // Move chicken up (between lanes)
  void moveChickenUp() {
    if (isGameActive && !isPaused && chickenLane > 0.0) {
      chickenLane -=
          0.25; // Move to upper lane (5 lanes: 0, 0.25, 0.5, 0.75, 1.0)
      if (chickenLane < 0.0) chickenLane = 0.0;
      _notifyStateChanged();
    }
  }

  // Move chicken down (between lanes)
  void moveChickenDown() {
    if (isGameActive && !isPaused && chickenLane < 1.0) {
      chickenLane +=
          0.25; // Move to lower lane (5 lanes: 0, 0.25, 0.5, 0.75, 1.0)
      if (chickenLane > 1.0) chickenLane = 1.0;
      _notifyStateChanged();
    }
  }

  // Cash out
  void cashOut() {
    if (isGameActive) {
      balance += cashOutAmount;
      showCashOutAnimation = true;
      isGameActive = false;
      _gameTimer?.cancel();
      _notifyStateChanged();

      // Hide cash out animation after a delay
      Timer(const Duration(milliseconds: 800), () {
        showCashOutAnimation = false;
        _notifyStateChanged();
      });
    }
  }

  // Update bet selection
  void updateBet(int newBet) {
    selectedBet = newBet;
    if (!isGameActive) {
      cashOutAmount = selectedBet.toDouble();
    }
    _notifyStateChanged();
  }

  // Update difficulty selection
  void updateDifficulty(String newDifficulty) {
    selectedDifficulty = newDifficulty;
    _notifyStateChanged();
  }

  // Pause/unpause game
  void togglePause() {
    isPaused = !isPaused;
    _notifyStateChanged();
  }

  // Start the game loop
  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isGameActive || isPaused) {
        return;
      }

      // Move the chicken forward in the world
      chickenWorldX += 0.02 * gameSpeed;
      // Move the road/background for visual effect
      backgroundOffset += 0.02 * gameSpeed;
      // Update multiplier based on distance traveled
      _updateMultiplier();
      // Generate obstacles and coins relative to chicken's world position
      _generateGameObjects();
      // Update positions of all game objects
      _updateGameObjects();
      // Check for collisions
      _checkCollisions();

      _notifyStateChanged();
    });
  }

  // Update multiplier progression
  void _updateMultiplier() {
    // Find the next multiplier level
    for (int i = 0; i < multiplierLevels.length; i++) {
      if (currentMultiplier < multiplierLevels[i]) {
        // Gradually increase toward next level
        double multiplierRate =
            difficultySettings[selectedDifficulty]!['multiplierRate'];
        currentMultiplier += multiplierRate * gameSpeed;

        // Cap at the next level
        if (currentMultiplier > multiplierLevels[i]) {
          currentMultiplier = multiplierLevels[i];
        }

        // Update cash out amount
        cashOutAmount = selectedBet * currentMultiplier;
        break;
      }
    }
  }

  // Generate game objects (obstacles, coins, multipliers)
  void _generateGameObjects() {
    // Generate cars (obstacles) that move vertically down the lanes
    if (math.Random().nextDouble() <
        0.05 * difficultySettings[selectedDifficulty]!['obstacleFrequency']) {
      final lane =
          math.Random().nextInt(5) / 4; // 5 lanes (0, 0.25, 0.5, 0.75, 1.0)
      final type = math.Random().nextInt(3); // 3 types of cars
      obstacles.add(
        Obstacle(
          lane: lane,
          position: 1.0, // Not used for world-based, but kept for compatibility
          type: type,
          worldX:
              chickenWorldX +
              math.Random().nextDouble() * 2.0, // Relative to chicken
          verticalPosition: -0.1, // Start above the screen
        ),
      );
    }

    // Random coin generation - also move vertically
    if (math.Random().nextDouble() < 0.03) {
      final lane = math.Random().nextInt(5) / 4; // 5 lanes vertically
      coins.add(
        Coin(
          lane: lane,
          position: 1.0,
          value: math.Random().nextInt(3) + 1,
          worldX: chickenWorldX + math.Random().nextDouble() * 2.0,
          verticalPosition: -0.1, // Start above the screen
        ),
      );
    }

    // Generate static manholes on the road ahead of chicken
    // Place manholes on all lanes at regular intervals
    final manholeSpacing = 3.0; // Distance between manhole rows
    final lookAheadDistance = 20.0; // How far ahead to place manholes

    // Calculate the farthest manhole position
    final farthestManholeX = manholes.isNotEmpty
        ? manholes.map((m) => m.worldX).reduce((a, b) => a > b ? a : b)
        : 0.0;

    // Generate new manholes if needed
    if (farthestManholeX < chickenWorldX + lookAheadDistance) {
      final startX = farthestManholeX == 0
          ? chickenWorldX + 4.0
          : farthestManholeX + manholeSpacing;

      // Create manholes across all lanes at regular intervals
      for (
        double x = startX;
        x < chickenWorldX + lookAheadDistance;
        x += manholeSpacing
      ) {
        // Place manholes on all 5 lanes at this x position
        for (int lane = 0; lane < 5; lane++) {
          final lanePosition = lane / 4.0; // 5 lanes: 0, 0.25, 0.5, 0.75, 1.0
          manholes.add(
            Manhole(
              lane: lanePosition,
              worldX: x,
              verticalPosition: lanePosition, // Static vertical position
            ),
          );
        }
      }
    }
  }

  // Update positions of all game objects
  void _updateGameObjects() {
    // Update cars (obstacles) - move them down vertically
    for (int i = obstacles.length - 1; i >= 0; i--) {
      obstacles[i].verticalPosition += 0.03 * gameSpeed; // Move down

      // Remove cars that have passed the bottom
      if (obstacles[i].verticalPosition > 1.2) {
        obstacles.removeAt(i);
      }
    }

    // Update coins - also move them down vertically
    for (int i = coins.length - 1; i >= 0; i--) {
      coins[i].verticalPosition += 0.03 * gameSpeed; // Move down

      // Remove coins that have passed the bottom
      if (coins[i].verticalPosition > 1.2) {
        coins.removeAt(i);
      }
    }

    // Update manholes - animate transformation if activated
    for (int i = manholes.length - 1; i >= 0; i--) {
      manholes[i].updateTransformation();

      // Remove manholes that have been passed by the chicken or are too far behind
      if (manholes[i].worldX < chickenWorldX - 1.0) {
        manholes.removeAt(i);
      }
    }

    // Update floating texts
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].update();
      if (floatingTexts[i].isExpired) {
        floatingTexts.removeAt(i);
      }
    }
  }

  // Check for collisions and interactions
  void _checkCollisions() {
    if (!isGameActive) return;

    // Check for car (obstacle) collisions - cars move vertically, chicken moves horizontally
    for (final obstacle in obstacles) {
      // Check if car is in the same lane as chicken and at the chicken's vertical position
      if ((obstacle.lane - chickenLane).abs() < 0.15 &&
          (obstacle.verticalPosition - chickenHorizontalPos).abs() < 0.1) {
        // Show collision animation
        showCollisionAnimation = true;
        Timer(const Duration(milliseconds: 500), () {
          showCollisionAnimation = false;
          _notifyStateChanged();
        });

        // Decrease lives
        chickenLives--;

        if (chickenLives <= 0) {
          _gameOver();
        } else {
          // Remove this car
          obstacles.remove(obstacle);
          _notifyStateChanged();
          break;
        }
      }
    }

    // Check for coin collections - coins also move vertically
    for (int i = coins.length - 1; i >= 0; i--) {
      if ((coins[i].lane - chickenLane).abs() < 0.15 &&
          (coins[i].verticalPosition - chickenHorizontalPos).abs() < 0.1) {
        // Collect coin
        final coinValue = coins[i].value; // capture value
        score += coinValue;
        coinsCounted += coinValue;
        showCoinCollectionAnimation = true;
        coins.removeAt(i); // remove coin

        Timer(const Duration(milliseconds: 300), () {
          showCoinCollectionAnimation = false;
          _notifyStateChanged();
        });

        // Boost multiplier
        final boost = 0.05 * coinValue;
        currentMultiplier += boost; // apply boost
        cashOutAmount = selectedBet * currentMultiplier;

        // Add floating text for multiplier boost
        floatingTexts.add(
          FloatingText(
            text: '+${boost.toStringAsFixed(2)}x',
            position: chickenWorldX,
            lane: chickenLane,
          ),
        );
        break;
      }
    }

    // Check for manhole interactions - chicken can activate manholes
    for (int i = manholes.length - 1; i >= 0; i--) {
      final manhole = manholes[i];
      if (!manhole.isActivated &&
          (manhole.lane - chickenLane).abs() < 0.15 &&
          (manhole.worldX - chickenWorldX).abs() < 0.3) {
        // Activate manhole transformation
        manhole.startTransformation();

        // Transform manhole into coin after animation completes
        Timer(const Duration(milliseconds: 500), () {
          // Create a coin at the manhole's position
          coins.add(
            Coin(
              lane: manhole.lane,
              position: 1.0,
              value: 2, // Higher value for transformed coin
              worldX: manhole.worldX,
              verticalPosition:
                  manhole.lane, // Coin appears at the manhole's lane position
            ),
          );

          // Remove the manhole
          if (manholes.contains(manhole)) {
            manholes.remove(manhole);
          }
          _notifyStateChanged();
        });
        break;
      }
    }
  }

  // Game over
  void _gameOver() {
    isGameActive = false;
    isGameOver = true;
    _gameTimer?.cancel();
    _notifyStateChanged();
  }

  // Notify UI of state changes
  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  // Dispose resources
  void dispose() {
    _gameTimer?.cancel();
  }
}
