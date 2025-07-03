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
  double multiplier; // Multiplier value for this manhole

  Manhole({
    required this.lane,
    required this.worldX,
    required this.verticalPosition,
    required this.multiplier,
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

class Barrier {
  double horizontalPos; // Horizontal position (0-1)
  double verticalPos; // Vertical position (0-1)

  Barrier({required this.horizontalPos, required this.verticalPos});
}

// Game state and logic controller
class ChickenRoadGame {
  // Game state
  bool isGameActive = false;
  bool isGameOver = false;
  bool isPaused = false;
  double currentMultiplier = 0.0; // Start with 0 gold
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

  // Slide animation for infinite gameplay
  bool isSlideAnimating = false;
  double slideOffset = 0.0; // For slide animation (-1.0 to 0.0)
  int currentLevel = 1; // Current level/slide number

  // Game objects
  List<Obstacle> obstacles = [];
  List<Multiplier> visibleMultipliers = [];
  List<FloatingText> floatingTexts = [];
  List<Manhole> manholes = []; // Track manholes separately
  List<Barrier> barriers = []; // Track barriers for activated manholes

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

    // Reset slide animation
    isSlideAnimating = false;
    slideOffset = 0.0;
    currentLevel = 1;
    currentMultiplier = 0.0; // Start with 0 instead of 1.0
    cashOutAmount = 0.0; // Start with 0 gold
    gameSpeed = difficultySettings[selectedDifficulty]!['gameSpeed'];
    chickenLives = difficultySettings[selectedDifficulty]!['lives'];
    obstacles.clear();
    visibleMultipliers.clear();
    floatingTexts.clear();
    manholes.clear(); // Clear manholes
    barriers.clear(); // Clear barriers

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
    if (!isGameActive || isPaused || isSlideAnimating) return;

    // Check if chicken has completed all manholes - trigger slide to next level
    if (currentManholeStep >= maxManholeSteps) {
      _startSlideToNextLevel();
      return;
    }

    // Find the next manhole to move to
    if (currentManholeStep < currentLineManholePositions.length) {
      final targetWorldX = currentLineManholePositions[currentManholeStep];

      // Move chicken to center lane where all manholes are located
      chickenLane = 0.5; // All manholes are on center lane

      // Move chicken to the next manhole position
      chickenWorldX = targetWorldX;
      // Update horizontal position to match lane centers: [0.3, 0.5, 0.7, 0.9]
      List<double> laneCenters = [0.3, 0.5, 0.7, 0.9];
      chickenHorizontalPos =
          laneCenters[currentManholeStep]; // Move to exact manhole position

      // Activate the manhole at current step
      if (currentManholeStep < manholes.length) {
        final manhole = manholes[currentManholeStep];
        if (!manhole.isActivated) {
          manhole.startTransformation();

          // Create a barrier above the activated manhole
          // Use the same position as the manhole, but store world coordinates
          barriers.add(
            Barrier(
              horizontalPos:
                  laneCenters[currentManholeStep], // UI position (0.3, 0.5, 0.7, 0.9)
              verticalPos: 0.5, // Same vertical position as manholes
            ),
          );

          // Add gold based on manhole's multiplier
          if (currentMultiplier == 0.0) {
            // First manhole: set multiplier to 1.0
            currentMultiplier = 1.0;
          } else {
            // Subsequent manholes: add the manhole's multiplier to current multiplier
            currentMultiplier += manhole.multiplier;
          }
          cashOutAmount =
              currentMultiplier; // Direct gold amount, not multiplied by bet
          score += 5; // Fixed score boost

          // Add floating text for gold boost
          floatingTexts.add(
            FloatingText(
              text:
                  '+${currentMultiplier == 1.0 ? '1.0' : manhole.multiplier.toStringAsFixed(1)} Gold',
              position: chickenWorldX,
              lane: chickenLane,
            ),
          );
        }
      }

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
      // Define lane centers: 0.1, 0.3, 0.5, 0.7, 0.9
      final List<double> laneCenters = [0.1, 0.3, 0.5, 0.7, 0.9];
      final currentIndex = laneCenters.indexOf(chickenLane);
      if (currentIndex > 0) {
        chickenLane =
            laneCenters[currentIndex - 1]; // Move to upper lane center
      }

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
      // Define lane centers: 0.1, 0.3, 0.5, 0.7, 0.9
      final List<double> laneCenters = [0.1, 0.3, 0.5, 0.7, 0.9];
      final currentIndex = laneCenters.indexOf(chickenLane);
      if (currentIndex >= 0 && currentIndex < laneCenters.length - 1) {
        chickenLane =
            laneCenters[currentIndex + 1]; // Move to lower lane center
      }

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
    // No automatic multiplier increase - only manual through manhole activation
    // Update cash out amount based on current multiplier (direct gold amount)
    cashOutAmount = currentMultiplier;
  }

  // Generate game objects (obstacles, coins, multipliers)
  void _generateGameObjects() {
    // Generate cars (obstacles) that move vertically down the lanes
    if (math.Random().nextDouble() <
        0.05 * difficultySettings[selectedDifficulty]!['obstacleFrequency']) {
      // Define lane centers between dashed lines
      // Road is divided into 5 lanes: 0-0.2, 0.2-0.4, 0.4-0.6, 0.6-0.8, 0.8-1.0
      // Centers are at: 0.1, 0.3, 0.5, 0.7, 0.9
      final List<double> laneCenters = [0.1, 0.3, 0.5, 0.7, 0.9];
      final laneIndex = math.Random().nextInt(laneCenters.length);
      final lane = laneCenters[laneIndex]; // Choose random lane center

      final type = math.Random().nextInt(4); // 4 types of cars (car1-4.png)
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

      // Generate random multiplier between 1.1 and 3.0
      final multiplier = 1.1 + (math.Random().nextDouble() * 1.9); // 1.1 to 3.0

      manholes.add(
        Manhole(
          lane: 0.5, // All manholes on the same horizontal line (center)
          worldX: worldX,
          verticalPosition: 0.5, // All on same vertical position
          multiplier: multiplier,
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

      // Generate random multiplier between 1.1 and 3.0
      final multiplier = 1.1 + (math.Random().nextDouble() * 1.9); // 1.1 to 3.0

      manholes.add(
        Manhole(
          lane: 0.5, // All manholes on the same horizontal line (center)
          worldX: worldX,
          verticalPosition: 0.5, // All on same vertical position
          multiplier: multiplier,
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

      // NEVER remove manholes that have been transformed to coins - they stay forever
      // Only remove manholes that are far behind and NOT activated (not used)
      if (manholes[i].worldX < chickenWorldX - 1.0 &&
          !manholes[i].isActivated) {
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

    // Barriers are created once when manholes are activated
    // and stay forever - no need to update them here
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

    // Check for manhole interactions - now handled in moveChickenForward()
    // No need to check here anymore since manholes are activated directly when chicken moves to them
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

  // Start slide animation to next level
  void _startSlideToNextLevel() {
    isSlideAnimating = true;
    slideOffset = 0.0;
    currentLevel++;
    _notifyStateChanged();

    // Animate slide effect
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      slideOffset -= 0.05; // Move slide left

      if (slideOffset <= -1.0) {
        timer.cancel();
        _completeSlideToNextLevel();
      }

      _notifyStateChanged();
    });
  }

  // Complete slide animation and reset for next level
  void _completeSlideToNextLevel() {
    // Reset chicken position
    currentManholeStep = 0;
    chickenHorizontalPos = 0.1;

    // Clear old objects except barriers and activated manholes (they stay forever)
    obstacles.clear();
    floatingTexts.clear();

    // Keep activated manholes and barriers from previous level but clear non-activated ones
    manholes.removeWhere((manhole) => !manhole.isActivated);

    // Generate new manholes for the new level
    _generateInitialManholes();

    // Reset slide animation
    isSlideAnimating = false;
    slideOffset = 0.0;

    _notifyStateChanged();
  }
}
