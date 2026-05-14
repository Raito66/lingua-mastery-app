class WordBook {
  final int id;
  final String name;
  final String language;
  final int wordCount;

  const WordBook({
    required this.id,
    required this.name,
    required this.language,
    required this.wordCount,
  });

  factory WordBook.fromJson(Map<String, dynamic> json) {
    return WordBook(
      id: json['id'] as int,
      name: json['name'] as String,
      language: json['language'] as String,
      wordCount: json['wordCount'] as int,
    );
  }

  String get languageLabel => language == 'JAPANESE' ? '🇯🇵 日文' : '🇺🇸 英文';
}
