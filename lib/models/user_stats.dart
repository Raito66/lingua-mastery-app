class UserStats {
  final int totalXp;
  final int streak;         // 連續學習天數
  final int englishKnown;   // 已學英文單字數
  final int japaneseKnown;  // 已學日文單字數
  final DateTime? lastStudyDate;

  const UserStats({
    this.totalXp = 0,
    this.streak = 0,
    this.englishKnown = 0,
    this.japaneseKnown = 0,
    this.lastStudyDate,
  });

  UserStats copyWith({
    int? totalXp,
    int? streak,
    int? englishKnown,
    int? japaneseKnown,
    DateTime? lastStudyDate,
  }) {
    return UserStats(
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      englishKnown: englishKnown ?? this.englishKnown,
      japaneseKnown: japaneseKnown ?? this.japaneseKnown,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'streak': streak,
        'englishKnown': englishKnown,
        'japaneseKnown': japaneseKnown,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    DateTime? lastStudyDate;
    try {
      if (json['lastStudyDate'] != null) {
        lastStudyDate = DateTime.parse(json['lastStudyDate'] as String);
      }
    } catch (_) {
      // 日期格式損壞時忽略，重置為 null
      lastStudyDate = null;
    }

    return UserStats(
      totalXp: json['totalXp'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      englishKnown: json['englishKnown'] as int? ?? 0,
      japaneseKnown: json['japaneseKnown'] as int? ?? 0,
      lastStudyDate: lastStudyDate,
    );
  }
}
