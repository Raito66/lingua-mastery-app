import 'dart:convert';
import '../models/word.dart';
import '../models/word_book.dart';
import 'api_service.dart';

class WordService {
  static Future<List<WordBook>> getBooks() async {
    final res = await ApiService.get('/api/books');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => WordBook.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Word>> getStudyWords(int bookId) async {
    final res = await ApiService.get('/api/study/$bookId');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Word.fromApiJson(e)).toList();
    }
    return [];
  }

  static Future<bool> updateBook(int bookId, String name, String language) async {
    final res = await ApiService.put('/api/books/$bookId', {
      'name': name,
      'language': language,
    });
    return res.statusCode == 200;
  }

  static Future<void> submitResult(int wordId, bool correct) async {
    await ApiService.post('/api/study/result', {
      'wordId': wordId,
      'correct': correct,
    });
  }

  static Future<Map<String, dynamic>?> getStats() async {
    final res = await ApiService.get('/api/stats');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }
}
