import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Color palette matching the game
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color panelGrey = Color(0xFF0F3460);
  static const Color greyMultiplier = Color(0xFF0F3460);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentBlue = Color(0xFF2ECC71);

  // Settings instance
  final GameSettings _settings = GameSettings();

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
            'SETTINGS',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Audio Settings
              _buildSettingsSection('AUDIO', [
                _buildSwitchSetting(
                  'Sound Effects',
                  _settings.soundEnabled,
                  CupertinoIcons.volume_up,
                  (value) => setState(() => _settings.soundEnabled = value),
                ),
                _buildSwitchSetting(
                  'Background Music',
                  _settings.musicEnabled,
                  CupertinoIcons.music_note,
                  (value) => setState(() => _settings.musicEnabled = value),
                ),
                _buildSliderSetting(
                  'Master Volume',
                  _settings.masterVolume,
                  CupertinoIcons.speaker_3,
                  (value) => setState(() => _settings.masterVolume = value),
                ),
              ]),

              const SizedBox(height: 30),

              // Gameplay Settings
              _buildSettingsSection('GAMEPLAY', [
                _buildSwitchSetting(
                  'Vibration',
                  _settings.vibrationEnabled,
                  CupertinoIcons.device_phone_portrait,
                  (value) => setState(() => _settings.vibrationEnabled = value),
                ),
                _buildSwitchSetting(
                  'Show Animations',
                  _settings.showAnimations,
                  CupertinoIcons.sparkles,
                  (value) => setState(() => _settings.showAnimations = value),
                ),
                _buildSwitchSetting(
                  'Auto Collect Coins',
                  _settings.autoCollectCoins,
                  CupertinoIcons.money_dollar_circle,
                  (value) => setState(() => _settings.autoCollectCoins = value),
                ),
                _buildSelectionSetting(
                  'Default Difficulty',
                  _settings.defaultDifficulty,
                  CupertinoIcons.flame,
                  ['Easy', 'Medium', 'Hard'],
                  (value) =>
                      setState(() => _settings.defaultDifficulty = value),
                ),
                _buildSelectionSetting(
                  'Default Bet',
                  '\$${_settings.defaultBet}',
                  CupertinoIcons.money_dollar,
                  ['\$1', '\$2', '\$5'],
                  (value) => setState(
                    () => _settings.defaultBet = int.parse(value.substring(1)),
                  ),
                ),
              ]),

              const SizedBox(height: 30),

              // Display Settings
              _buildSettingsSection('DISPLAY', [
                _buildSwitchSetting(
                  'Reduced Motion',
                  _settings.reducedMotion,
                  CupertinoIcons.eye_slash,
                  (value) => setState(() => _settings.reducedMotion = value),
                ),
                _buildSliderSetting(
                  'UI Scale',
                  _settings.uiScale,
                  CupertinoIcons.textformat_size,
                  (value) => setState(() => _settings.uiScale = value),
                  min: 0.5,
                  max: 2.0,
                  showPercentage: false,
                ),
              ]),

              const SizedBox(height: 30),

              // Notifications Settings
              _buildSettingsSection('NOTIFICATIONS', [
                _buildSwitchSetting(
                  'Push Notifications',
                  _settings.notificationsEnabled,
                  CupertinoIcons.bell,
                  (value) =>
                      setState(() => _settings.notificationsEnabled = value),
                ),
              ]),

              const SizedBox(height: 30),

              // About Section
              _buildSettingsSection('ABOUT', [
                _buildInfoSetting('Version', '1.0.0', CupertinoIcons.info),
                _buildPrivacyPolicySetting(),
              ]),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [panelGrey, greyMultiplier],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: goldColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? goldColor : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? darkBackground : whiteText,
              size: 16,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: whiteText, fontSize: 14),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: goldColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    IconData icon,
    Function(double) onChanged, {
    double min = 0.0,
    double max = 1.0,
    bool showPercentage = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goldColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: darkBackground, size: 16),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(color: whiteText, fontSize: 14),
              ),
              const Spacer(),
              Text(
                showPercentage
                    ? '${(value * 100).round()}%'
                    : '${value.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: goldColor,
            thumbColor: goldColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSetting(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: whiteText, size: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: whiteText, fontSize: 14),
            ),
          ),
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

  Widget _buildSelectionSetting(
    String title,
    String currentValue,
    IconData icon,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: whiteText, size: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: whiteText, fontSize: 14),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: panelGrey,
            borderRadius: BorderRadius.circular(8),
            onPressed: () =>
                _showSelectionDialog(title, currentValue, options, onChanged),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentValue,
                  style: const TextStyle(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: goldColor,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicySetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showPrivacyDialog(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.shield,
                color: whiteText,
                size: 16,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(color: whiteText, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'We don\'t collect or send any personal data',
                    style: TextStyle(
                      color: whiteText.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: goldColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Select $title',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: options.map((option) {
          return CupertinoActionSheetAction(
            isDefaultAction: option == currentValue,
            onPressed: () {
              onChanged(option);
              Navigator.pop(context);
            },
            child: Text(
              option,
              style: TextStyle(
                color: option == currentValue
                    ? goldColor
                    : CupertinoColors.systemBlue,
                fontWeight: option == currentValue
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Chicken Road Ultimate respects your privacy.\n\n'
          'We do not collect, store, or transmit any personal data.\n\n'
          'All game data is stored locally on your device and never sent to external servers.\n\n'
          'Your privacy is important to us and we are committed to protecting it.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Got it!'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
