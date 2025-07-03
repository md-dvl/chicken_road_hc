import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  // Settings state
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool notificationsEnabled = false;
  double volume = 0.5;

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Audio Settings
              _buildSettingsSection('AUDIO', [
                _buildSwitchSetting(
                  'Sound Effects',
                  soundEnabled,
                  CupertinoIcons.volume_up,
                  (value) => setState(() => soundEnabled = value),
                ),
                _buildSliderSetting(
                  'Volume',
                  volume,
                  CupertinoIcons.speaker_1,
                  (value) => setState(() => volume = value),
                ),
              ]),

              const SizedBox(height: 30),

              // Gameplay Settings
              _buildSettingsSection('GAMEPLAY', [
                _buildSwitchSetting(
                  'Vibration',
                  vibrationEnabled,
                  CupertinoIcons.device_phone_portrait,
                  (value) => setState(() => vibrationEnabled = value),
                ),
                _buildSwitchSetting(
                  'Notifications',
                  notificationsEnabled,
                  CupertinoIcons.bell,
                  (value) => setState(() => notificationsEnabled = value),
                ),
              ]),

              const SizedBox(height: 30),

              // About Section
              _buildSettingsSection('ABOUT', [
                _buildInfoSetting('Version', '1.0.0', CupertinoIcons.info),
                _buildInfoSetting(
                  'Developer',
                  'Game Studio',
                  CupertinoIcons.person,
                ),
              ]),

              const Spacer(),

              // Placeholder message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: panelGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: goldColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Settings functionality will be implemented soon!\nCustomize your gaming experience here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

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
    Function(double) onChanged,
  ) {
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
                '${(value * 100).round()}%',
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
}
