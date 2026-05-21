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

  final _japLevels = const [
    ('', '無'),
    ('JLPT_N5', 'N5'), ('JLPT_N4', 'N4'), ('JLPT_N3', 'N3'),
    ('JLPT_N2', 'N2'), ('JLPT_N1', 'N1'),
  ];
  final _engLevels = const [
    ('', '無'),
    ('TOEIC_300', 'TOEIC 300↓'),
    ('TOEIC_300_500', 'TOEIC 300-500'),
    ('TOEIC_500_700', 'TOEIC 500-700'),
    ('TOEIC_700_900', 'TOEIC 700-900'),
    ('TOEIC_900PLUS', 'TOEIC 900+'),
  ];

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

  List<(String, String)> get _levels =>
      widget.book.language == 'JAPANESE' ? _japLevels : _engLevels;

  // ── 新增 / 編輯 bottom sheet ─────────────────────────────────────────────

  Future<void> _showWordForm({Word? editWord}) async {
    final wordCtrl = TextEditingController(text: editWord?.word ?? '');
    final readingCtrl = TextEditingController(text: editWord?.reading ?? '');
    final transCtrl = TextEditingController(text: editWord?.translation ?? '');
    final exampleCtrl = TextEditingController(text: editWord?.example ?? '');
    String selectedLevel = editWord?.apiLevel ?? '';
    String? errorMsg;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    editWord == null ? '新增單字' : '編輯單字',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _field(wordCtrl, '單字 *', hint: 'e.g. 猫 / apple'),
                  const SizedBox(height: 12),
                  if (widget.book.language == 'JAPANESE') ...[
                    _field(readingCtrl, '讀音', hint: 'e.g. ねこ'),
                    const SizedBox(height: 12),
                  ],
                  _field(transCtrl, '翻譯 *', hint: 'e.g. 貓'),
                  const SizedBox(height: 12),
                  _field(exampleCtrl, '例句', hint: '選填'),
                  const SizedBox(height: 12),
                  // Level dropdown
                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: '等級',
                      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _levels.map((e) => DropdownMenuItem(
                      value: e.$1,
                      child: Text(e.$2),
                    )).toList(),
                    onChanged: (v) => setSheetState(() => selectedLevel = v ?? ''),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 10),
                    Text(errorMsg!, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : () async {
                        final w = wordCtrl.text.trim();
                        final t = transCtrl.text.trim();
                        if (w.isEmpty || t.isEmpty) {
                          setSheetState(() => errorMsg = '單字與翻譯為必填');
                          return;
                        }
                        setSheetState(() { saving = true; errorMsg = null; });
                        try {
                          if (editWord == null) {
                            await WordService.addWord(
                              widget.book.id,
                              word: w,
                              reading: readingCtrl.text.trim(),
                              translation: t,
                              example: exampleCtrl.text.trim(),
                              level: selectedLevel,
                              language: widget.book.language,
                            );
                          } else {
                            final id = int.parse(editWord.id);
                            await WordService.updateWord(
                              id,
                              word: w,
                              reading: readingCtrl.text.trim(),
                              translation: t,
                              example: exampleCtrl.text.trim(),
                              level: selectedLevel,
                              language: widget.book.language,
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } catch (e) {
                          setSheetState(() { saving = false; errorMsg = e.toString().replaceFirst('Exception: ', ''); });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6AFA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(editWord == null ? '新增' : '儲存', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    wordCtrl.dispose(); readingCtrl.dispose();
    transCtrl.dispose(); exampleCtrl.dispose();
  }

  Widget _field(TextEditingController ctrl, String label, {String hint = ''}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        filled: true,
        fillColor: Colors.white10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── 刪除確認 ────────────────────────────────────────────────────────────

  Future<void> _deleteWord(Word word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('確定刪除？', style: TextStyle(color: Colors.white)),
        content: Text(
          '「${word.word}」將被永久刪除。',
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('刪除', style: TextStyle(color: Color(0xFFFF5252))),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await WordService.deleteWord(int.parse(word.id));
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  // ── Proficiency badge ───────────────────────────────────────────────────

  ({String label, Color color}) _badge(int level) {
    switch (level) {
      case 3: return (label: '已精通', color: const Color(0xFFCE93D8));
      case 2: return (label: '已熟悉', color: const Color(0xFF69F0AE));
      case 1: return (label: '學習中', color: const Color(0xFFFFD54F));
      default: return (label: '未學習', color: Colors.white38);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isJapanese = widget.book.language == 'JAPANESE';
    final bookColor = isJapanese ? const Color(0xFFE53935) : const Color(0xFF3D5AFE);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showWordForm();
          if (mounted) _load();
        },
        backgroundColor: const Color(0xFF7C6AFA),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
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
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              itemCount: _words.length,
                              itemBuilder: (context, index) =>
                                  _buildWordTile(_words[index]),
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
    final flex = (ratio * 1000).round().clamp(1, 1000);
    return Flexible(
      flex: flex,
      child: Container(color: ratio > 0 ? color : Colors.transparent),
    );
  }

  Widget _buildCount(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
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
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: badge.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
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
          const SizedBox(width: 8),
          // ⋯ 選單
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 20),
            color: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'edit') {
                await _showWordForm(editWord: word);
                if (mounted) _load();
              } else if (value == 'delete') {
                await _deleteWord(word);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                    SizedBox(width: 10),
                    Text('編輯', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5252), size: 18),
                    SizedBox(width: 10),
                    Text('刪除', style: TextStyle(color: Color(0xFFFF5252))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
