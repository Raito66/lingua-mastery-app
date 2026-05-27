import 'dart:convert';
import '../models/word.dart';
import '../models/word_book.dart';
import '../models/quiz_question.dart';
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

  static Future<List<Word>> getWords(int bookId) async {
    final res = await ApiService.get('/api/books/$bookId/words');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Word.fromApiJson(e)).toList();
    }
    throw Exception('載入單字失敗 (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> getBookStats(int bookId) async {
    final res = await ApiService.get('/api/stats/book/$bookId');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  static Future<List<Word>> getStudyWords(int bookId) async {
    final res = await ApiService.get('/api/study/$bookId');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Word.fromApiJson(e)).toList();
    }
    return [];
  }

  static Future<List<Word>> getReviewWords(int bookId) async {
    final res = await ApiService.get('/api/review/$bookId');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Word.fromApiJson(e)).toList();
    }
    return [];
  }

  static Future<void> submitReview(int wordId, bool correct) async {
    await ApiService.post('/api/review/result', {
      'wordId': wordId,
      'correct': correct,
    });
  }

  /// 回傳指定書本今日到期和新單字數量 (dueCount, newCount)，失敗時 throw Exception
  static Future<(int, int)> getBookReviewDetail(int bookId) async {
    final res = await ApiService.get('/api/review/stats');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      for (final e in data) {
        if ((e['bookId'] as num).toInt() == bookId) {
          return (
            (e['dueCount'] as num).toInt(),
            (e['newCount'] as num).toInt(),
          );
        }
      }
      return (0, 0); // 此書本今日無待複習
    }
    throw Exception('取得複習資料失敗 (${res.statusCode})');
  }

  /// 回傳 bookId -> 今日待複習數（到期 + 新單字）
  static Future<Map<int, int>> getReviewStats() async {
    final res = await ApiService.get('/api/review/stats');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return Map.fromEntries(data.map((e) => MapEntry(
        (e['bookId'] as num).toInt(),
        (e['dueCount'] as num).toInt() + (e['newCount'] as num).toInt(),
      )));
    }
    return {};
  }

  static Future<bool> createBook(String name, String language) async {
    final res = await ApiService.post('/api/books', {
      'name': name,
      'language': language,
    });
    return res.statusCode == 200;
  }

  static Future<bool> updateBook(int bookId, String name, String language) async {
    final res = await ApiService.put('/api/books/$bookId', {
      'name': name,
      'language': language,
    });
    return res.statusCode == 200;
  }

  static Future<bool> deleteBook(int bookId) async {
    final res = await ApiService.delete('/api/books/$bookId');
    return res.statusCode == 204;
  }

  static Future<Word> addWord(int bookId, {
    required String word,
    required String reading,
    required String translation,
    required String example,
    required String level,
    required String language,
  }) async {
    final res = await ApiService.post('/api/books/$bookId/words', {
      'word': word,
      'reading': reading,
      'translation': translation,
      'example': example,
      'level': level.isEmpty ? null : level,
      'language': language.toUpperCase(),
    });
    if (res.statusCode == 200) {
      return Word.fromApiJson(jsonDecode(res.body));
    }
    final msg = res.body.isNotEmpty
        ? jsonDecode(res.body)['message'] as String? ?? '新增失敗'
        : '新增失敗';
    throw Exception(msg);
  }

  static Future<Word> updateWord(int wordId, {
    required String word,
    required String reading,
    required String translation,
    required String example,
    required String level,
    required String language,
  }) async {
    final res = await ApiService.put('/api/words/$wordId', {
      'word': word,
      'reading': reading,
      'translation': translation,
      'example': example,
      'level': level.isEmpty ? null : level,
      'language': language.toUpperCase(),
    });
    if (res.statusCode == 200) {
      return Word.fromApiJson(jsonDecode(res.body));
    }
    final msg = res.body.isNotEmpty
        ? jsonDecode(res.body)['message'] as String? ?? '更新失敗'
        : '更新失敗';
    throw Exception(msg);
  }

  static Future<void> deleteWord(int wordId) async {
    final res = await ApiService.delete('/api/words/$wordId');
    if (res.statusCode != 204) {
      final msg = res.body.isNotEmpty
          ? jsonDecode(res.body)['message'] as String? ?? '刪除失敗'
          : '刪除失敗';
      throw Exception(msg);
    }
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

  static Future<Map<String, dynamic>?> getStreak() async {
    final res = await ApiService.get('/api/stats/streak');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  static Future<List<QuizQuestion>> getQuizQuestions(int bookId) async {
    final res = await ApiService.get('/api/quiz/$bookId');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => QuizQuestion.fromJson(e)).toList();
    }
    return [];
  }
}
