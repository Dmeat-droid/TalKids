import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/learning_model.dart';
import '../widgets/mascot_widget.dart';
import 'practice_screen.dart';
import '../core/services/score_service.dart';
import 'stats_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  LearningCategory _selectedCategory = LearningCategory.vokal;
  final ScoreService _scoreService = ScoreService();
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  void _loadStars() {
    setState(() {
      _stars = _scoreService.getStars();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on selected category
    final items = LearningItem.defaultItems
        .where((item) => item.category == _selectedCategory)
        .toList();

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
            icon: const Icon(Icons.arrow_back_rounded, color: KidTheme.textDark, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: KidTheme.textDark, width: 3),
            ),
            child: IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: KidTheme.textDark, size: 28),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatsScreen(),
                  ),
                );
                _loadStars();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Star Shelf (Rak Bintang)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: KidTheme.kidCardDecoration(
                  color: Colors.white,
                  borderColor: KidTheme.accentYellow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: KidTheme.accentYellow, size: 36),
                        const SizedBox(width: 8),
                        Text(
                          'BINTANGKU:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: KidTheme.textDark.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: KidTheme.accentYellow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: KidTheme.textDark, width: 2),
                      ),
                      child: Text(
                        '⭐ $_stars',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: KidTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Mascot instructions
            const MascotWidget(
              expression: MascotExpression.talking,
              speechBubbleText: 'Pilih materi belajar hari ini, ya!',
              size: 150,
            ),
            const SizedBox(height: 20),

            // High Contrast Category Selectors (2 Large Tabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // Tab Vokal
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = LearningCategory.vokal;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: KidTheme.kidCardDecoration(
                          color: _selectedCategory == LearningCategory.vokal
                              ? KidTheme.primaryBlue
                              : Colors.white,
                          borderColor: KidTheme.primaryBlue,
                        ),
                        child: Center(
                          child: Text(
                            'HURUF\nVOKAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _selectedCategory == LearningCategory.vokal
                                  ? Colors.white
                                  : KidTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tab Kata Sederhana
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = LearningCategory.kata;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: KidTheme.kidCardDecoration(
                          color: _selectedCategory == LearningCategory.kata
                              ? KidTheme.primaryOrange
                              : Colors.white,
                          borderColor: KidTheme.primaryOrange,
                        ),
                        child: Center(
                          child: Text(
                            'KATA\nSEDERHANA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _selectedCategory == LearningCategory.kata
                                  ? Colors.white
                                  : KidTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Headline for selected mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _selectedCategory == LearningCategory.vokal
                    ? 'Ketuk Huruf Vokal:'
                    : 'Ketuk Kata Pilihan:',
                style: KidTheme.themeData.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic grid of items
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Alternating item colors for child-friendly appearance
                  final Color cardColor = index % 2 == 0
                      ? KidTheme.accentYellow
                      : const Color(0xFFC3EEFF);
                  final Color borderColor = index % 2 == 0
                      ? KidTheme.primaryOrange
                      : KidTheme.primaryBlue;

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticeScreen(item: item),
                        ),
                      );
                      _loadStars();
                    },
                    child: Container(
                      decoration: KidTheme.kidCardDecoration(
                        color: cardColor,
                        borderColor: borderColor,
                      ),
                      child: Center(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontSize: _selectedCategory == LearningCategory.vokal ? 56 : 32,
                            fontWeight: FontWeight.w900,
                            color: KidTheme.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
