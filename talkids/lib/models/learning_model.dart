enum LearningCategory { vokal, kata }

class LearningItem {
  final String id;
  final String text;
  final String phoneticGuide;
  final LearningCategory category;
  final String instructionText;
  final String mouthGuideType; // 'A', 'I', 'U', 'E', 'O', or 'DEFAULT'

  const LearningItem({
    required this.id,
    required this.text,
    required this.phoneticGuide,
    required this.category,
    required this.instructionText,
    required this.mouthGuideType,
  });

  // Default database of learning items
  static List<LearningItem> get defaultItems {
    return [
      // Vowels (Vokal)
      const LearningItem(
        id: 'vokal_a',
        text: 'A',
        phoneticGuide: 'Buka mulut lebar seperti sedang tertawa.',
        category: LearningCategory.vokal,
        instructionText: 'Lihat mulut Tio! Buka lebar-lebar mulutmu dan ucapkan: A A A!',
        mouthGuideType: 'A',
      ),
      const LearningItem(
        id: 'vokal_i',
        text: 'I',
        phoneticGuide: 'Tarik bibir ke samping seperti tersenyum, gigi dirapatkan.',
        category: LearningCategory.vokal,
        instructionText: 'Tarik bibirmu seperti tersenyum, lihat Tio dan ucapkan: I I I!',
        mouthGuideType: 'I',
      ),
      const LearningItem(
        id: 'vokal_u',
        text: 'U',
        phoneticGuide: 'Monyongkan bibir ke depan membentuk lingkaran kecil.',
        category: LearningCategory.vokal,
        instructionText: 'Perhatikan bibir Tio, monyongkan bibirmu dan ucapkan: U U U!',
        mouthGuideType: 'U',
      ),
      const LearningItem(
        id: 'vokal_e',
        text: 'E',
        phoneticGuide: 'Buka bibir sedikit, gigi agak berjarak, lidah datar.',
        category: LearningCategory.vokal,
        instructionText: 'Buka mulut sedikit, perhatikan Tio dan ucapkan: E E E!',
        mouthGuideType: 'E',
      ),
      const LearningItem(
        id: 'vokal_o',
        text: 'O',
        phoneticGuide: 'Bentuk lingkaran sedang dengan bibirmu.',
        category: LearningCategory.vokal,
        instructionText: 'Lihat Tio, bulatkan bibirmu membentuk lingkaran dan ucapkan: O O O!',
        mouthGuideType: 'O',
      ),

      // Simple Words (Kata Sederhana)
      const LearningItem(
        id: 'kata_mama',
        text: 'MAMA',
        phoneticGuide: 'Rapatkan bibir (M), lalu buka lebar (A). Ulangi dua kali.',
        category: LearningCategory.kata,
        instructionText: 'Perhatikan mulut Tio, rapatkan bibir lalu buka lebar: MA-MA!',
        mouthGuideType: 'A',
      ),
      const LearningItem(
        id: 'kata_papa',
        text: 'PAPA',
        phoneticGuide: 'Kulum bibir sebentar, hembuskan udara keluar (P), lalu buka lebar (A).',
        category: LearningCategory.kata,
        instructionText: 'Lihat Tio, tiup udara dari bibir lalu buka lebar: PA-PA!',
        mouthGuideType: 'A',
      ),
      const LearningItem(
        id: 'kata_tio',
        text: 'TIO',
        phoneticGuide: 'Sentuhkan lidah ke gigi atas (T), tersenyum (I), lalu bulatkan bibir (O).',
        category: LearningCategory.kata,
        instructionText: 'Perhatikan gerakan mulut untuk: TI-O!',
        mouthGuideType: 'O',
      ),
      const LearningItem(
        id: 'kata_bola',
        text: 'BOLA',
        phoneticGuide: 'Rapatkan bibir (B), bulatkan bibir (O), lalu sentuh langit-langit dengan lidah (L-A).',
        category: LearningCategory.kata,
        instructionText: 'Lihat cara mengucapkan: BO-LA!',
        mouthGuideType: 'O',
      ),
    ];
  }
}
