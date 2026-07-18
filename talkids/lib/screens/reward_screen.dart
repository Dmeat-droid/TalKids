import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/services/score_service.dart';
import '../models/learning_model.dart';
import '../widgets/mascot_widget.dart';

class RewardScreen extends StatefulWidget {
  final LearningItem item;

  const RewardScreen({super.key, required this.item});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with TickerProviderStateMixin {
  late AnimationController _starController1;
  late AnimationController _starController2;
  late AnimationController _starController3;
  late AnimationController _xpController;

  late Animation<double> _scaleStar1;
  late Animation<double> _scaleStar2;
  late Animation<double> _scaleStar3;
  late Animation<double> _xpAnimation;

  final ScoreService _scoreService = ScoreService();
  late int _xpOld;
  late int _xpNew;
  late int _levelOld;
  late int _levelNew;
  late bool _didLevelUp;

  @override
  void initState() {
    super.initState();

    // Load XP state from ScoreService
    _xpNew = _scoreService.getXp();
    _xpOld = _xpNew - 10;
    if (_xpOld < 0) _xpOld = 0;

    _levelNew = _scoreService.getLevel();
    _levelOld = (_xpOld / 100).floor() + 1;
    _didLevelUp = _levelNew > _levelOld;

    double startProgress = (_xpOld % 100) / 100.0;
    double endProgress = _didLevelUp ? 1.0 : (_xpNew % 100) / 100.0;

    _xpController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1200),
    );
    _xpAnimation = Tween<double>(begin: startProgress, end: endProgress).animate(
      CurvedAnimation(parent: _xpController, curve: Curves.easeInOut),
    );

    // Setup staggered entrance animations for 3 stars
    _starController1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _starController2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _starController3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _scaleStar1 = CurvedAnimation(parent: _starController1, curve: Curves.elasticOut);
    _scaleStar2 = CurvedAnimation(parent: _starController2, curve: Curves.elasticOut);
    _scaleStar3 = CurvedAnimation(parent: _starController3, curve: Curves.elasticOut);

    // Stagger play
    Future.delayed(const Duration(milliseconds: 300), () => _starController1.forward());
    Future.delayed(const Duration(milliseconds: 700), () => _starController2.forward());
    Future.delayed(const Duration(milliseconds: 1100), () => _starController3.forward());

    // Start XP animation after stars pop up
    Future.delayed(const Duration(milliseconds: 1500), () => _xpController.forward());
  }

  @override
  void dispose() {
    _starController1.dispose();
    _starController2.dispose();
    _starController3.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0xFFFFFDF5),
                Color(0xFFFFF6CA),
              ],
              radius: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Congratulation Banner
              Column(
                children: [
                  const Text(
                    'HEBAT!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: KidTheme.primaryOrange,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamu berhasil mengucapkan "${widget.item.text}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KidTheme.textDark,
                    ),
                  ),
                ],
              ),

              // 3 Animating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Star 1 (Left, slightly rotated and smaller)
                  ScaleTransition(
                    scale: _scaleStar1,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: const Icon(
                        Icons.star_rounded,
                        size: 70,
                        color: KidTheme.accentYellow,
                        shadows: [Shadow(color: Colors.black12, offset: Offset(0, 4))],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Star 2 (Center, main big star)
                  ScaleTransition(
                    scale: _scaleStar2,
                    child: const Icon(
                      Icons.star_rounded,
                      size: 110,
                      color: KidTheme.accentYellow,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 6))],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Star 3 (Right, slightly rotated and smaller)
                  ScaleTransition(
                    scale: _scaleStar3,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: const Icon(
                        Icons.star_rounded,
                        size: 70,
                        color: KidTheme.accentYellow,
                        shadows: [Shadow(color: Colors.black12, offset: Offset(0, 4))],
                      ),
                    ),
                  ),
                ],
              ),

              // XP Progress & Level Up visual
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TIO LEVEL $_levelOld',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: KidTheme.primaryBlue,
                          ),
                        ),
                        if (_didLevelUp)
                          const Text(
                            '🎉 NAIK LEVEL!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: KidTheme.primaryOrange,
                            ),
                          )
                        else
                          Text(
                            '+10 XP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: KidTheme.textDark.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Animated Progress Bar Container
                    AnimatedBuilder(
                      animation: _xpAnimation,
                      builder: (context, child) {
                        return Container(
                          height: 24,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: KidTheme.textDark, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: _xpAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _didLevelUp ? KidTheme.primaryOrange : KidTheme.successGreen,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${(_xpAnimation.value * 100).toInt()} / 100 XP',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: KidTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Mascot Tio doing jumping animation
              MascotWidget(
                expression: MascotExpression.jumping,
                speechBubbleText: _didLevelUp 
                    ? 'Luar biasa! Tio sekarang naik ke Level $_levelNew! Terima kasih sahabat pintar! 🐬👑✨'
                    : 'Horeee! Suaramu terdengar sangat baik! Tio bangga padamu! 🐬✨',
                size: 160,
              ),

              // Large, glowing "Lanjut" button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: KidTheme.primaryBlue.withValues(alpha: 0.4),
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to levels select
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KidTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('LANJUT '),
                      Icon(Icons.arrow_forward_rounded, size: 30),
                    ],
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
