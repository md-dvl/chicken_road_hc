import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _titleAnimationController;
  late AnimationController _subtitleAnimationController;
  late AnimationController _buttonsAnimationController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _chickenAnimationController;
  late AnimationController _coinsAnimationController;

  // Animations
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _subtitleSlideAnimation;
  late Animation<double> _subtitleOpacityAnimation;
  late Animation<double> _buttonsSlideAnimation;
  late Animation<double> _buttonsOpacityAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _chickenBounceAnimation;
  late Animation<double> _coinsRotationAnimation;

  // Game color palette
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color roadGrey = Color(0xFF16213E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color greenButton = Color(0xFF00FF87);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color panelGrey = Color(0xFF0F3460);
  static const Color accentBlue = Color(0xFF2ECC71);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentOrange = Color(0xFFFF6B35);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Title animation
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _titleSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleAnimationController, curve: Curves.easeIn),
    );

    // Subtitle animation
    _subtitleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _subtitleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _subtitleAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _subtitleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _subtitleAnimationController,
        curve: Curves.easeIn,
      ),
    );

    // Buttons animation
    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonsSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _buttonsAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _buttonsOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsAnimationController,
        curve: Curves.easeIn,
      ),
    );

    // Background animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundAnimationController);

    // Chicken bounce animation
    _chickenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _chickenBounceAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _chickenAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Coins rotation animation
    _coinsAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _coinsRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_coinsAnimationController);
  }

  void _startAnimations() {
    // Staggered animation sequence
    _titleAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _subtitleAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _buttonsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _subtitleAnimationController.dispose();
    _buttonsAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _chickenAnimationController.dispose();
    _coinsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: darkBackground,
      child: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // Animated title
                          _buildAnimatedTitle(),

                          const SizedBox(height: 20),

                          // Animated chicken with coins
                          _buildAnimatedChicken(),

                          const SizedBox(height: 30),

                          // Animated subtitle
                          _buildAnimatedSubtitle(),

                          const SizedBox(height: 40),

                          // Game description
                          _buildGameDescription(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom buttons
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkBackground, roadGrey, darkBackground],
              stops: [
                0.0,
                0.5 + 0.3 * math.sin(_backgroundAnimation.value * 2 * math.pi),
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            painter: RoadLinesPainter(_backgroundAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _titleAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _titleSlideAnimation.value),
          child: Opacity(
            opacity: _titleOpacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Text(
                'CHICKEN ROAD\nULTIMATE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkBackground,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  height: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedChicken() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _chickenBounceAnimation,
        _coinsRotationAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_chickenBounceAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating coins around chicken
              for (int i = 0; i < 4; i++)
                Transform.rotate(
                  angle: _coinsRotationAnimation.value + (i * math.pi / 2),
                  child: Transform.translate(
                    offset: const Offset(60, 0),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: goldColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.money_dollar,
                        color: darkBackground,
                        size: 12,
                      ),
                    ),
                  ),
                ),

              // Central chicken
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: goldColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CustomPaint(painter: ChickenPainter()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedBuilder(
      animation: _subtitleAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _subtitleSlideAnimation.value),
          child: Opacity(
            opacity: _subtitleOpacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentPurple.withOpacity(0.8),
                    accentBlue.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: whiteText.withOpacity(0.3), width: 1),
              ),
              child: const Text(
                'The Ultimate Road Crossing Adventure',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: whiteText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [panelGrey.withOpacity(0.8), roadGrey.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.game_controller,
            color: goldColor,
            size: 40,
          ),
          const SizedBox(height: 15),
          const Text(
            'How to Play',
            style: TextStyle(
              color: goldColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            '🐔 Help the chicken cross the road safely\n'
            '💰 Collect coins and activate multipliers\n'
            '🚗 Avoid moving cars and obstacles\n'
            '🎯 Cash out before you crash\n'
            '🏆 Survive as long as possible!',
            textAlign: TextAlign.center,
            style: TextStyle(color: whiteText, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return AnimatedBuilder(
      animation: _buttonsAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _buttonsSlideAnimation.value),
          child: Opacity(
            opacity: _buttonsOpacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [panelGrey, darkBackground],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  top: BorderSide(color: goldColor.withOpacity(0.3), width: 2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start Game Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [greenButton, accentBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: greenButton.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: CupertinoButton(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      onPressed: () => _navigateToMainScreen(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.play_fill,
                            color: whiteText,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'START GAME',
                            style: TextStyle(
                              color: whiteText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Version info
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: whiteText.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => const MainScreen()),
    );
  }
}

// Custom painter for road lines background
class RoadLinesPainter extends CustomPainter {
  final double animation;

  RoadLinesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2;

    // Draw moving dashed lines
    for (int i = 1; i < 4; i++) {
      final x = (size.width / 4) * i;
      for (double y = -20; y < size.height + 20; y += 40) {
        final animatedY = y + (animation * 40) % 40;
        canvas.drawLine(Offset(x, animatedY), Offset(x, animatedY + 20), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for chicken
class ChickenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body
    final bodyPaint = Paint()..color = Colors.yellow;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.6,
        height: size.height * 0.7,
      ),
      bodyPaint,
    );

    // Beak
    final beakPaint = Paint()..color = Colors.orange;
    final beakPath = Path();
    beakPath.moveTo(
      center.dx + size.width * 0.2,
      center.dy - size.height * 0.1,
    );
    beakPath.lineTo(center.dx + size.width * 0.35, center.dy);
    beakPath.lineTo(
      center.dx + size.width * 0.2,
      center.dy + size.height * 0.1,
    );
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.1, center.dy - size.height * 0.15),
      size.width * 0.05,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.15),
      size.width * 0.05,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
