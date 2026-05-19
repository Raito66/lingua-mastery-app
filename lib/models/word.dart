class Word {
  final String id;
  final String word;
  final String reading;           // 假名讀音（日文用）
  final String romaji;            // 羅馬字（日文用）
  final String translation;       // 中文翻譯
  final String example;           // 例句
  final String exampleTranslation;
  final String language;          // 'english' | 'japanese'
  final String level;             // 'beginner' | 'intermediate' | 'advanced'
  final int proficiencyLevel;     // 0=未學習 1=學習中 2=已熟悉 3=已精通

  const Word({
    required this.id,
    required this.word,
    this.reading = '',
    this.romaji = '',
    required this.translation,
    required this.example,
    this.exampleTranslation = '',
    required this.language,
    required this.level,
    this.proficiencyLevel = 0,
  });

  factory Word.fromJson(Map<String, dynamic> json, String language) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      reading: (json['reading'] as String?) ?? '',
      romaji: (json['romaji'] as String?) ?? '',
      translation: json['translation'] as String,
      example: json['example'] as String,
      exampleTranslation: (json['exampleTranslation'] as String?) ?? '',
      language: language,
      level: json['level'] as String,
    );
  }

  // 從後端 API 解析
  factory Word.fromApiJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'].toString(),
      word: json['word'] as String,
      reading: (json['reading'] as String?) ?? '',
      romaji: '',
      translation: json['translation'] as String,
      example: (json['example'] as String?) ?? '',
      exampleTranslation: '',
      language: (json['language'] as String).toLowerCase(),
      level: _mapLevel(json['level'] as String? ?? ''),
      proficiencyLevel: (json['proficiencyLevel'] as int?) ?? 0,
    );
  }

  static String _mapLevel(String apiLevel) {
    switch (apiLevel) {
      case 'JLPT_N1': return 'advanced';
      case 'JLPT_N2': return 'intermediate';
      case 'TOEIC_900PLUS':
      case 'TOEIC_700_900': return 'advanced';
      case 'TOEIC_500_700': return 'intermediate';
      default: return 'beginner';
    }
  }
}
