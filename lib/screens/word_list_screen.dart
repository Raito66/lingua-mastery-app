import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/word_book.dart';
import '../services/word_service.dart';

class WordListScreen extends StatefulWidget {
  final WordBook book;

  const WordListScreen({super.key, required this.book});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _words = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final words = await WordService.getWords(widget.book.id);
      if (mounted) setState(() { _words = words; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  ({String label, Color color}) _badge(int level) {
    switch (level) {
      case 3: return (label: '已精通', color: const Color(0xFFCE93D8));
      case 2: return (label: '已熟悉', color: const Color(0xFF69F0AE));
      case 1: return (label: '學習中', color: const Color(0xFFFFD54F));
      default: return (label: '未學習', color: Colors.white38);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isJapanese = widget.book.language == 'JAPANESE';
    final bookColor = isJapanese ? const Color(0xFFE53935) : const Color(0xFF3D5AFE);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
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
          : _error != null
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
          : _words.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📭', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('這個單字本還沒有單字',
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildProgressBar(bookColor),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _words.length,
                          itemBuilder: (context, index) => _buildWordTile(_words[index]),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProgressBar(Color bookColor) {
    final counts = [0, 0, 0, 0];
    for (final w in _words) {
      counts[w.proficiencyLevel.clamp(0, 3)]++;
    }
    final total = _words.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // 進度條
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  _progressSegment(counts[3] / total, const Color(0xFFCE93D8)),
                  _progressSegment(counts[2] / total, const Color(0xFF69F0AE)),
                  _progressSegment(counts[1] / total, const Color(0xFFFFD54F)),
                  _progressSegment(counts[0] / total, Colors.white12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 數量統計
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCount('已精通', counts[3], const Color(0xFFCE93D8)),
              _buildCount('已熟悉', counts[2], const Color(0xFF69F0AE)),
              _buildCount('學習中', counts[1], const Color(0xFFFFD54F)),
              _buildCount('未學習', counts[0], Colors.white38),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressSegment(double ratio, Color color) {
    final flex = (ratio * 1000).round().clamp(1, 1000); // 最小 1 避免全零時條消失
    return Flexible(
      flex: flex,
      child: Container(color: ratio > 0 ? color : Colors.transparent),
    );
  }

  Widget _buildCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildWordTile(Word word) {
    final badge = _badge(word.proficiencyLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // 熟練度指示條
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: badge.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          // 單字內容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (word.reading.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        word.reading,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  word.translation,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // 熟練度 badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badge.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badge.color.withOpacity(0.4)),
            ),
            child: Text(
              badge.label,
              style: TextStyle(color: badge.color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
