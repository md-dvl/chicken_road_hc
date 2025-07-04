class GameSession {
  final int score;
  final double earnings;
  final double maxMultiplier;
  final String difficulty;
  final int bet;
  final DateTime date;
  final int stepsCompleted;
  final bool cashedOut;

  GameSession({
    required this.score,
    required this.earnings,
    required this.maxMultiplier,
    required this.difficulty,
    required this.bet,
    required this.date,
    required this.stepsCompleted,
    required this.cashedOut,
  });
}

class SessionStats {
  static final SessionStats _instance = SessionStats._internal();
  factory SessionStats() => _instance;
  SessionStats._internal();

  final List<GameSession> _sessions = [];

  void addSession(GameSession session) {
    _sessions.add(session);
    // Ограничиваем количество сессий в памяти (последние 50 игр)
    if (_sessions.length > 50) {
      _sessions.removeAt(0);
    }
  }

  List<GameSession> get sessions => List.unmodifiable(_sessions);

  void clearSessions() {
    _sessions.clear();
  }

  // Статистики
  int get totalGames => _sessions.length;

  int get bestScore => _sessions.isEmpty
      ? 0
      : _sessions.map((s) => s.score).reduce((a, b) => a > b ? a : b);

  double get totalEarnings => _sessions.fold(0.0, (sum, s) => sum + s.earnings);

  double get bestMultiplier => _sessions.isEmpty
      ? 0.0
      : _sessions.map((s) => s.maxMultiplier).reduce((a, b) => a > b ? a : b);

  int get successfulCashouts => _sessions.where((s) => s.cashedOut).length;

  // Достижения (проверяем на основе текущих данных)
  bool get hasFirstGame => _sessions.isNotEmpty;
  bool get hasScore10 => _sessions.any((s) => s.score >= 10);
  bool get hasScore50 => _sessions.any((s) => s.score >= 50);
  bool get hasScore100 => _sessions.any((s) => s.score >= 100);
  bool get hasMultiplier5x => _sessions.any((s) => s.maxMultiplier >= 5.0);
  bool get hasMultiplier10x => _sessions.any((s) => s.maxMultiplier >= 10.0);
  bool get hasCashout100 =>
      _sessions.any((s) => s.cashedOut && s.earnings >= 100);
  bool get hasSurvivor => _sessions.any((s) => s.stepsCompleted >= 20);
  bool get hasHardcorePlayer =>
      _sessions.any((s) => s.difficulty == 'Hard' && s.cashedOut);
  bool get hasLuckyStreak => successfulCashouts >= 5;
  bool get hasBigSpender => _sessions.any((s) => s.bet >= 5);
  bool get hasVeteran => totalGames >= 50;
}
