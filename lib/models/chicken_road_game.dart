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
  bool isFromManhole; // Whether this coin came from a manhole transformation

  Coin({
    required this.lane,
    required this.position,
    required this.value,
    required this.worldX,
    required this.verticalPosition,
    this.isFromManhole = false, // Default to false for regular coins
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
  bool isTransformedToCoin = false; // Whether it's now showing as coin
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
        isTransformedToCoin = true; // Now show as coin
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

  // Manhole movement restrictions
  int currentManholeStep = 0; // Current step (0-4)
  static const int maxManholeSteps = 4; // Maximum steps per line
  List<double> currentLineManholePositions =
      []; // X positions of manholes on current line

  // Game scrolling
  double backgroundOffset = 0.0;
  double gameSpeed = 1.0;

  // Game objects
  List<Obstacle> obstacles = [];
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
    visibleMultipliers.clear();
    floatingTexts.clear();
    manholes.clear(); // Clear manholes

    // Reset manhole movement tracking
    currentManholeStep = 0;
    currentLineManholePositions.clear();

    // Generate initial manholes for the current line
    _generateInitialManholes();

    score = 0;
    coinsCounted = 0;
    showCashOutAnimation = false;
    showCollisionAnimation = false;
    showCoinCollectionAnimation = false;
    _notifyStateChanged();
  }

  // Constructor - generate manholes on creation
  ChickenRoadGame() {
    _generateInitialManholes();
  }

  // Start the game (only starts obstacles/cars, not chicken movement)
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
        _startGameLoop(); // This will start cars moving
        _notifyStateChanged();
        return true;
      } else {
        // Insufficient funds
        onShowMessage?.call("Insufficient funds!");
        return false;
      }
    }
    return true;
  }

  // Move chicken forward (call this on "Go" button press)
  void moveChickenForward() {
    if (!isGameActive || isPaused) return;

    // Check if chicken can make another step
    if (currentManholeStep >= maxManholeSteps) {
      // All steps used, cannot move further
      return;
    }

    // Find the next manhole to move to
    if (currentManholeStep < currentLineManholePositions.length) {
      final targetWorldX = currentLineManholePositions[currentManholeStep];

      // Move chicken to center lane where all manholes are located
      chickenLane = 0.5; // All manholes are on center lane

      // Move chicken to the next manhole position
      chickenWorldX = targetWorldX;
      chickenHorizontalPos =
          0.1 + (currentManholeStep + 1) * 0.2; // Move right on screen
      currentManholeStep++;

      // Clamp horizontal position
      if (chickenHorizontalPos > 0.9) {
        chickenHorizontalPos = 0.9;
      }

      _notifyStateChanged();
    }
  }

  // Move chicken up (between lanes)
  void moveChickenUp() {
    if (isGameActive && !isPaused && chickenLane > 0.0) {
      chickenLane -=
          0.25; // Move to upper lane (5 lanes: 0, 0.25, 0.5, 0.75, 1.0)
      if (chickenLane < 0.0) chickenLane = 0.0;

      // Reset step counter and generate new manhole line
      currentManholeStep = 0;
      chickenHorizontalPos = 0.1; // Reset to starting position
      _generateNewManholeLineForCurrentLane();

      _notifyStateChanged();
    }
  }

  // Move chicken down (between lanes)
  void moveChickenDown() {
    if (isGameActive && !isPaused && chickenLane < 1.0) {
      chickenLane +=
          0.25; // Move to lower lane (5 lanes: 0, 0.25, 0.5, 0.75, 1.0)
      if (chickenLane > 1.0) chickenLane = 1.0;

      // Reset step counter and generate new manhole line
      currentManholeStep = 0;
      chickenHorizontalPos = 0.1; // Reset to starting position
      _generateNewManholeLineForCurrentLane();

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

      // Don't move chicken automatically - only move on manual input
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

    // No need to generate manholes here - they are generated when chicken changes lanes
    // or at game start through _generateInitialManholes() and _generateNewManholeLineForCurrentLane()
  }

  // Generate initial manholes for the current lane
  void _generateInitialManholes() {
    currentLineManholePositions.clear();
    manholes.clear();

    // Create 4 manholes in a horizontal line, all at the center lane (0.5)
    // but at different horizontal positions representing 4 lanes between dashed lines
    // Lane centers between dashed lines: 0.3, 0.5, 0.7, 0.9 (excluding first lane)

    for (int i = 0; i < maxManholeSteps; i++) {
      final worldX =
          chickenWorldX + 2.0 + (i * 1.5); // Space manholes 1.5 units apart
      currentLineManholePositions.add(worldX);

      manholes.add(
        Manhole(
          lane: 0.5, // All manholes on the same horizontal line (center)
          worldX: worldX,
          verticalPosition: 0.5, // All on same vertical position
        ),
      );
    }
  }

  // Generate new manhole line for current lane
  void _generateNewManholeLineForCurrentLane() {
    currentLineManholePositions.clear();

    // Remove old manholes that are not activated
    manholes.removeWhere((manhole) => !manhole.isActivated);

    // Create 4 new manholes in a horizontal line, all at the center lane (0.5)
    // but at different horizontal positions representing 4 lanes between dashed lines

    for (int i = 0; i < maxManholeSteps; i++) {
      final worldX =
          chickenWorldX + 2.0 + (i * 1.5); // Space manholes 1.5 units apart
      currentLineManholePositions.add(worldX);

      manholes.add(
        Manhole(
          lane: 0.5, // All manholes on the same horizontal line (center)
          worldX: worldX,
          verticalPosition: 0.5, // All on same vertical position
        ),
      );
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

    // Check for manhole interactions - chicken can only activate manholes it steps directly on
    for (int i = manholes.length - 1; i >= 0; i--) {
      final manhole = manholes[i];
      if (!manhole.isActivated &&
          (manhole.lane - chickenLane).abs() < 0.1 && // Same lane as chicken
          (manhole.worldX - chickenWorldX).abs() < 0.2) {
        // Chicken is at manhole position
        // Activate manhole transformation
        manhole.startTransformation();

        // Just boost multiplier when manhole is activated
        final boost = 0.1; // Fixed boost for manhole activation
        currentMultiplier += boost;
        cashOutAmount = selectedBet * currentMultiplier;
        score += 5; // Fixed score boost

        // Add floating text for multiplier boost
        floatingTexts.add(
          FloatingText(
            text: '+${boost.toStringAsFixed(2)}x',
            position: chickenWorldX,
            lane: chickenLane,
          ),
        );

        _notifyStateChanged();
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
