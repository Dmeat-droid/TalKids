import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/mascot_widget.dart';
import 'category_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Continuous pulsing animation for the "MULAI" button to grab children's attention
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Title Area
              Column(
                children: [
                  Text(
                    'TalKids',
                    style: KidTheme.themeData.textTheme.displayLarge?.copyWith(
                      color: KidTheme.primaryBlue,
                      fontSize: 48,
                      shadows: [
                        const Shadow(
                          color: Colors.white,
                          offset: Offset(3, 3),
                        ),
                        Shadow(
                          color: KidTheme.textDark.withValues(alpha: 0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Belajar Bicara Bersama Tio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KidTheme.textDark,
                    ),
                  ),
                ],
              ),

              // Mascot Widget with speech bubble
              const MascotWidget(
                expression: MascotExpression.greeting,
                speechBubbleText: 'Halo sahabat pintar! Aku Tio. Yuk kita belajar bersuara bersama!',
                size: 220,
              ),

              // Giant Pulsing Button
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: KidTheme.primaryOrange.withValues(alpha: 0.4),
                        offset: const Offset(0, 10),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('MULAI '),
                        Icon(Icons.play_arrow_rounded, size: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
