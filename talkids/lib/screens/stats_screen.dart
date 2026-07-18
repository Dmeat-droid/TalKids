import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/services/score_service.dart';
import '../models/learning_model.dart';
import '../widgets/mascot_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ScoreService _scoreService = ScoreService();
  
  int _stars = 0;
  int _xp = 0;
  int _level = 1;
  int _streak = 0;
  Map<String, int> _practiceCounts = {};
  List<int> _weeklyActivity = [];
  List<String> _dayInitials = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _stars = _scoreService.getStars();
      _xp = _scoreService.getXp();
      _level = _scoreService.getLevel();
      _streak = _scoreService.getStreak();
      _practiceCounts = _scoreService.getPracticeCounts();
      _weeklyActivity = _scoreService.getWeeklyActivity();
      _dayInitials = _calculateDayInitials();
    });
  }

  List<String> _calculateDayInitials() {
    const days = ['M', 'S', 'S', 'R', 'K', 'J', 'S']; // Min, Sen, Sel, Rab, Kam, Jum, Sab (weekday: 1=Senin, 7=Minggu)
    DateTime now = DateTime.now();
    List<String> initials = [];
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      int index = day.weekday == 7 ? 0 : day.weekday; // Map 7 (Minggu) to index 0, 1 to 1, etc.
      initials.add(days[index]);
    }
    return initials;
  }



  @override
  Widget build(BuildContext context) {
    // XP progress in current level (100 XP per level)
    int xpInCurrentLevel = _xp % 100;
    double xpProgress = xpInCurrentLevel / 100.0;
    int xpToNextLevel = 100 - xpInCurrentLevel;

    // Find the maximum value in weekly activity for scaling the chart
    int maxActivity = _weeklyActivity.isEmpty 
        ? 1 
        : _weeklyActivity.reduce((curr, next) => curr > next ? curr : next);
    if (maxActivity == 0) maxActivity = 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: KidTheme.textDark, width: 3),
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: KidTheme.textDark, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'CATATAN PRESTASI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: KidTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TIO LEVEL CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: KidTheme.kidCardDecoration(
                  color: Colors.white,
                  borderColor: KidTheme.primaryBlue,
                ),
                child: Row(
                  children: [
                    // Tio Mini representation
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: KidTheme.primaryBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: KidTheme.primaryBlue, width: 3),
                      ),
                      child: const Center(
                        child: MascotWidget(
                          expression: MascotExpression.greeting,
                          size: 70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Level info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TIO (LEVEL $_level)',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: KidTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$xpToNextLevel XP lagi untuk naik level!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: KidTheme.textDark.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Custom XP Progress Bar
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: KidTheme.textDark, width: 2),
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: xpProgress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: KidTheme.successGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$xpInCurrentLevel / 100 XP',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: KidTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. METRICS CARDS (STREAK & STARS)
              Row(
                children: [
                  // Streak Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: KidTheme.kidCardDecoration(
                        color: Colors.white,
                        borderColor: KidTheme.primaryOrange,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🔥 STREAK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: KidTheme.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_streak Hari',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: KidTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Latihan Berturut',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Total Stars Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: KidTheme.kidCardDecoration(
                        color: Colors.white,
                        borderColor: KidTheme.accentYellow,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '⭐ BINTANG',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_stars Buah',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: KidTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Terkumpul',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. WEEKLY ACTIVITY CHART
              const Text(
                'AKTIVITAS 7 HARI TERAKHIR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: KidTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: KidTheme.kidCardDecoration(
                  color: Colors.white,
                  borderColor: KidTheme.primaryBlue.withValues(alpha: 0.5),
                ),
                child: Column(
                  children: [
                    // Simple custom bar chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        int count = _weeklyActivity[index];
                        // Scale bar height to max 100px
                        double barHeight = (count / maxActivity) * 100;
                        if (barHeight < 8 && count > 0) barHeight = 8; // min visible height if count > 0

                        return Column(
                          children: [
                            // Count value label
                            Text(
                              count > 0 ? '$count' : '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: KidTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Bar container
                            Container(
                              width: 24,
                              height: barHeight == 0 ? 6 : barHeight,
                              decoration: BoxDecoration(
                                color: barHeight == 0 
                                    ? Colors.grey.shade200 
                                    : KidTheme.primaryBlue,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                border: Border.all(
                                  color: barHeight == 0 ? Colors.grey.shade300 : KidTheme.textDark,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Day initial label
                            Text(
                              _dayInitials[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: KidTheme.textDark,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. DETAILED LOG OF PRACTICE ITEMS
              const Text(
                'RIWAYAT LATIHAN MATERI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: KidTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: LearningItem.defaultItems.length,
                itemBuilder: (context, index) {
                  final item = LearningItem.defaultItems[index];
                  final int practicedCount = _practiceCounts[item.id] ?? 0;
                  final bool isVowel = item.category == LearningCategory.vokal;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isVowel ? KidTheme.primaryBlue.withValues(alpha: 0.3) : KidTheme.primaryOrange.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Avatar/Mouth Guide Placeholder icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isVowel 
                                    ? KidTheme.primaryBlue.withValues(alpha: 0.1) 
                                    : KidTheme.primaryOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isVowel ? '👄' : '💬',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Syllable text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.text,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: KidTheme.textDark,
                                  ),
                                ),
                                Text(
                                  isVowel ? 'Huruf Vokal' : 'Kata Sederhana',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: KidTheme.textDark.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Practice Counter Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: practicedCount > 0 
                                ? KidTheme.successGreen.withValues(alpha: 0.2) 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: practicedCount > 0 ? KidTheme.successGreen : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: practicedCount > 0 ? KidTheme.successGreen : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$practicedCount Kali',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: practicedCount > 0 ? KidTheme.successGreen.withValues(alpha: 0.9) : Colors.grey,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
