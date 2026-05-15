import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/word_book.dart';
import '../services/word_service.dart';
import '../widgets/flashcard_widget.dart';
import 'result_screen.dart';

class FlashcardScreen extends StatefulWidget {
  final WordBook book;
  final bool isReviewMode;

  const FlashcardScreen({super.key, required this.book, this.isReviewMode = false});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Word> _words = [];
  int _currentIndex = 0;
  int _knownCount = 0;
  int _dontKnowCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = widget.isReviewMode
        ? await WordService.getReviewWords(widget.book.id)
        : await WordService.getStudyWords(widget.book.id);
    if (mounted) {
      setState(() {
        _words = words;
        _loading = false;
      });
    }
  }

  void _handleKnow() {
    final wordId = int.tryParse(_words[_currentIndex].id);
    if (wordId != null) {
      if (widget.isReviewMode) {
        WordService.submitReview(wordId, true).catchError((_) {});
      } else {
        WordService.submitResult(wordId, true);
      }
    }
    setState(() => _knownCount++);
    _nextCard();
  }

  void _handleDontKnow() {
    final wordId = int.tryParse(_words[_currentIndex].id);
    if (wordId != null) {
      if (widget.isReviewMode) {
        WordService.submitReview(wordId, false).catchError((_) {});
      } else {
        WordService.submitResult(wordId, false);
      }
    }
    setState(() => _dontKnowCount++);
    _nextCard();
  }

  void _nextCard() {
    if (_currentIndex + 1 >= _words.length) {
      _finish();
    } else {
      setState(() => _currentIndex++);
    }
  }

  void _finish() {
    final xpGained = _knownCount * 10;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          book: widget.book,
          language: widget.book.language.toLowerCase(),
          level: '',
          total: _words.length,
          knownCount: _knownCount,
          dontKnowCount: _dontKnowCount,
          xpGained: xpGained,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7C6AFA))),
      );
    }

    if (_words.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('這本單字本還沒有單字', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final progress = (_currentIndex + 1) / _words.length;
    final langLabel = widget.book.language == 'JAPANESE' ? '🇯🇵 日文' : '🇺🇸 英文';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$langLabel  ${widget.book.name}',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_words.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C6AFA)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('✓ $_knownCount',
                      style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 13)),
                  Text('✗ $_dontKnowCount',
                      style: const TextStyle(color: Color(0xFFFF5252), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FlashcardWidget(
                  key: ValueKey(_words[_currentIndex].id),
                  word: _words[_currentIndex],
                  onKnow: _handleKnow,
                  onDontKnow: _handleDontKnow,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
