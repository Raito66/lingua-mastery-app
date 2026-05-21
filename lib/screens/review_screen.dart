import 'dart:async';
import 'package:flutter/material.dart';
import '../models/word_book.dart';
import '../services/word_service.dart';
import 'flashcard_screen.dart';

class ReviewScreen extends StatefulWidget {
  final WordBook book;

  const ReviewScreen({super.key, required this.book});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _dueCount = 0;
  int _newCount = 0;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = false; });
    try {
      final detail = await WordService.getBookReviewDetail(widget.book.id);
      if (mounted) {
        setState(() {
          _dueCount = detail.$1;
          _newCount = detail.$2;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[ReviewScreen._load] error: $e');
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  Future<void> _startReview() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(book: widget.book, isReviewMode: true),
      ),
    );
    if (mounted) unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final isJapanese = widget.book.language == 'JAPANESE';
    final total = _dueCount + _newCount;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              isJapanese ? '🇯🇵 日文' : '🇺🇸 英文',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6AFA)))
          : _error
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text('載入失敗，請重試',
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _load,
                        child: const Text('重試', style: TextStyle(color: Color(0xFF7C6AFA))),
                      ),
                    ],
                  ),
                )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C6AFA).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF7C6AFA).withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.repeat_rounded, color: Color(0xFF7C6AFA), size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '今日複習',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    if (total == 0) ...[
                      const Spacer(),
                      const Text('🎉', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      const Text(
                        '今天已複習完畢！',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '明天再來繼續吧',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const Spacer(),
                    ] else ...[
                      Row(
                        children: [
                          _statCard('到期複習', _dueCount, const Color(0xFF7C6AFA)),
                          const SizedBox(width: 16),
                          _statCard('新單字', _newCount, const Color(0xFF69F0AE)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '共 $total 張待複習',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C6AFA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text(
                            '開始複習',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
