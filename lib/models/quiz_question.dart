class QuizQuestion {
  final int wordId;
  final String word;
  final String? reading;
  final String language;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.wordId,
    required this.word,
    this.reading,
    required this.language,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      wordId: json['wordId'] as int,
      word: json['word'] as String,
      reading: json['reading'] as String?,
      language: json['language'] as String,
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'] as int,
    );
  }
}
