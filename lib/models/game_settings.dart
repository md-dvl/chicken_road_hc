import 'package:flutter/foundation.dart';

class GameSettings extends ChangeNotifier {
  // Audio settings
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _masterVolume = 0.7;

  // Gameplay settings
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = false;
  bool _showAnimations = true;
  bool _autoCollectCoins = false;

  // Display settings
  bool _reducedMotion = false;
  String _theme = 'Dark'; // 'Dark' or 'Light'
  double _uiScale = 1.0;

  // Difficulty presets
  String _defaultDifficulty = 'Medium';
  int _defaultBet = 2;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get masterVolume => _masterVolume;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get showAnimations => _showAnimations;
  bool get autoCollectCoins => _autoCollectCoins;
  bool get reducedMotion => _reducedMotion;
  String get theme => _theme;
  double get uiScale => _uiScale;
  String get defaultDifficulty => _defaultDifficulty;
  int get defaultBet => _defaultBet;

  // Setters
  set soundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  set musicEnabled(bool value) {
    _musicEnabled = value;
    notifyListeners();
  }

  set masterVolume(double value) {
    _masterVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  set vibrationEnabled(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
  }

  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  set showAnimations(bool value) {
    _showAnimations = value;
    notifyListeners();
  }

  set autoCollectCoins(bool value) {
    _autoCollectCoins = value;
    notifyListeners();
  }

  set reducedMotion(bool value) {
    _reducedMotion = value;
    notifyListeners();
  }

  set theme(String value) {
    _theme = value;
    notifyListeners();
  }

  set uiScale(double value) {
    _uiScale = value.clamp(0.5, 2.0);
    notifyListeners();
  }

  set defaultDifficulty(String value) {
    _defaultDifficulty = value;
    notifyListeners();
  }

  set defaultBet(int value) {
    _defaultBet = value;
    notifyListeners();
  }
}
