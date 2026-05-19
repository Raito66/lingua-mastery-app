import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_question.dart';
import '../models/word_book.dart';
import '../services/word_service.dart';

class QuizScreen extends StatefulWidget {
  final WordBook book;

  const QuizScreen({super.key, required this.book});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _index = 0;
  int _correct = 0;
  int _wrong = 0;
  bool _loading = true;
  bool _answered = false;
  int? _selected;

  final FlutterTts _tts = FlutterTts();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initTts().then((_) => _loadQuiz()).catchError((_) => _loadQuiz());
  }

  @override
  void dispose() {
    _disposed = true;
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    final lang = widget.book.language == 'JAPANESE' ? 'ja-JP' : 'en-US';
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.7);
    await _tts.speak('.');
    await Future.delayed(const Duration(milliseconds: 300));
    await _tts.stop();
  }

  Future<void> _loadQuiz() async {
    final questions = await WordService.getQuizQuestions(widget.book.id);
    if (mounted) {
      setState(() {
        _questions = questions;
        _index = 0;
        _correct = 0;
        _wrong = 0;
        _answered = false;
        _selected = null;
        _loading = false;
      });
      if (questions.isNotEmpty) _speak(questions[0].word);
    }
  }

  Future<void> _speak(String text) async {
    if (_disposed) return;
    await _tts.speak(text);
  }

  void _handleSelect(int optionIndex) {
    if (_answered) return;
    final q = _questions[_index];
    final isCorrect = optionIndex == q.correctIndex;

    setState(() {
      _selected = optionIndex;
      _answered = true;
      if (isCorrect) _correct++; else _wrong++;
    });

    WordService.submitResult(q.wordId, isCorrect).catchError((_) {});
  }

  void _handleNext() {
    if (_index + 1 >= _questions.length) {
      setState(() => _loading = true); // 觸發結果畫面
      _showResult();
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
    _speak(_questions[_index].word);
  }

  void _showResult() {
    final total = _questions.length;
    final accuracy = total > 0 ? (_correct / total * 100).round() : 0;
    final emoji = accuracy >= 80 ? '🎉' : accuracy >= 50 ? '💪' : '📖';
    final color = const Color(0xFF7C6AFA);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('本次測驗結果',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _resultStat('總題數', '$total', Colors.white70),
                _resultStat('答對', '$_correct', Colors.greenAccent),
                _resultStat('答錯', '$_wrong', Colors.redAccent),
              ],
            ),
            const SizedBox(height: 16),
            Text('$accuracy%',
                style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold)),
            const Text('正確率', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // back to home
                    },
                    child: const Text('回首頁', style: TextStyle(color: Colors.white54)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _loading = true);
                      _loadQuiz();
                    },
                    child: const Text('再來一次', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF7C6AFA))),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('沒有單字可以測驗', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final q = _questions[_index];
    final total = _questions.length;
    final progress = _index / total;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(widget.book.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                  Text('${_index + 1} / $total',
                      style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7C6AFA)),
              minHeight: 3,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // 單字卡
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        children: [
                          Text(q.word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold)),
                          if (q.reading != null && q.reading!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(q.reading!,
                                style: const TextStyle(color: Colors.white54, fontSize: 18)),
                          ],
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _speak(q.word),
                            child: const Icon(Icons.volume_up_rounded,
                                color: Colors.white24, size: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 選項
                    ...q.options.asMap().entries.map((entry) {
                      final i = entry.key;
                      final option = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOption(i, option, q.correctIndex),
                      );
                    }),
                    if (_answered) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C6AFA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _handleNext,
                          child: Text(
                            _index + 1 >= total ? '查看結果' : '下一題 →',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int i, String option, int correctIndex) {
    Color borderColor = Colors.white12;
    Color bgColor = const Color(0xFF1A1A2E);
    Color textColor = Colors.white70;
    IconData? icon;
    Color? iconColor;
    double borderWidth = 1;

    if (_answered) {
      if (i == correctIndex) {
        borderColor = Colors.greenAccent;
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.greenAccent;
        icon = Icons.check_circle_rounded;
        iconColor = Colors.greenAccent;
        borderWidth = 2;
      } else if (i == _selected) {
        borderColor = Colors.redAccent;
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.redAccent;
        icon = Icons.cancel_rounded;
        iconColor = Colors.redAccent;
        borderWidth = 2;
      } else {
        textColor = Colors.white24;
        borderColor = Colors.white.withOpacity(0.05);
      }
    }

    return GestureDetector(
      onTap: () => _handleSelect(i),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(option,
                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            if (icon != null) Icon(icon, color: iconColor, size: 22),
          ],
        ),
      ),
    );
  }
}
