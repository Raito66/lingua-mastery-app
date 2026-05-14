import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordRepository {
  static List<Word>? _englishWords;
  static List<Word>? _japaneseWords;

  static Future<void> init() async {
    if (_englishWords != null) return;

    final enJson = await rootBundle.loadString('assets/words/english.json');
    final jpJson = await rootBundle.loadString('assets/words/japanese.json');

    final enList = jsonDecode(enJson) as List<dynamic>;
    final jpList = jsonDecode(jpJson) as List<dynamic>;

    _englishWords = enList.map((e) => Word.fromJson(e as Map<String, dynamic>, 'english')).toList();
    _japaneseWords = jpList.map((e) => Word.fromJson(e as Map<String, dynamic>, 'japanese')).toList();
  }

  static List<Word> getWords({required String language, required String level}) {
    final all = language == 'english' ? (_englishWords ?? []) : (_japaneseWords ?? []);
    return all.where((w) => w.level == level).toList();
  }

  static int totalCount(String language) {
    return (language == 'english' ? _englishWords : _japaneseWords)?.length ?? 0;
  }
}
