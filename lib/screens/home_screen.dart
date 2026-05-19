import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_book.dart';
import '../services/word_service.dart';
import '../services/auth_service.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'word_list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WordBook> _books = [];
  Map<String, dynamic>? _stats;
  Map<int, int> _reviewCounts = {};
  int _streak = 0;
  int _todayCount = 0;
  bool _loading = true;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final results = await Future.wait([
      WordService.getBooks(),
      WordService.getStats(),
      WordService.getReviewStats(),
      WordService.getStreak(),
    ]);
    final books = results[0] as List<WordBook>;
    final stats = results[1] as Map<String, dynamic>?;
    final reviewCounts = results[2] as Map<int, int>;
    final streakData = results[3] as Map<String, dynamic>?;
    if (mounted) {
      setState(() {
        _email = email;
        _books = books;
        _stats = stats;
        _reviewCounts = reviewCounts;
        _streak = (streakData?['streak'] as int?) ?? 0;
        _todayCount = (streakData?['todayCount'] as int?) ?? 0;
        _loading = false;
      });
    }
  }

  Future<void> _createBook() async {
    final nameCtrl = TextEditingController();
    String selectedLanguage = 'JAPANESE';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('新增單字本', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '名稱',
                  hintText: '例如：JLPT N1、多益必考',
                  hintStyle: const TextStyle(color: Colors.white24),
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '語言',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'JAPANESE', child: Text('🇯🇵 日文')),
                  DropdownMenuItem(value: 'ENGLISH', child: Text('🇺🇸 英文')),
                ],
                onChanged: (v) => setDialogState(() => selectedLanguage = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final ok = await WordService.createBook(name, selectedLanguage);
                if (!context.mounted) return;
                Navigator.pop(ctx);
                if (ok) {
                  _load();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('新增失敗，請稍後再試')),
                  );
                }
              },
              child: const Text('新增', style: TextStyle(color: Color(0xFF7C6AFA))),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }

  Future<void> _editBook(WordBook book) async {
    final nameCtrl = TextEditingController(text: book.name);
    String selectedLanguage = book.language;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('編輯單字本', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '名稱',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '語言',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'JAPANESE', child: Text('🇯🇵 日文')),
                  DropdownMenuItem(value: 'ENGLISH', child: Text('🇺🇸 英文')),
                ],
                onChanged: (v) => setDialogState(() => selectedLanguage = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('確定刪除？', style: TextStyle(color: Colors.white)),
                    content: Text('「${book.name}」及其所有單字將被永久刪除。',
                        style: const TextStyle(color: Colors.white54)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('取消', style: TextStyle(color: Colors.white54)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('刪除', style: TextStyle(color: Color(0xFFFF5252))),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final ok = await WordService.deleteBook(book.id);
                  if (!context.mounted) return;
                  if (ok) {
                    _load();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('刪除失敗，請稍後再試')),
                    );
                  }
                }
              },
              child: const Text('刪除', style: TextStyle(color: Color(0xFFFF5252))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final ok = await WordService.updateBook(book.id, name, selectedLanguage);
                if (!context.mounted) return;
                Navigator.pop(ctx);
                if (ok) {
                  _load();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('更新失敗，請稍後再試')),
                  );
                }
              },
              child: const Text('儲存', style: TextStyle(color: Color(0xFF7C6AFA))),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }

  Future<void> _goToWordList(WordBook book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WordListScreen(book: book)),
    );
    if (mounted) _load();
  }

  Future<void> _goToStudy(WordBook book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlashcardScreen(book: book)),
    );
    if (mounted) _load();
  }

  Future<void> _goToQuiz(WordBook book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(book: book)),
    );
    if (mounted) _load();
  }

  Future<void> _goToReview(WordBook book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlashcardScreen(book: book, isReviewMode: true)),
    );
    if (mounted) _load();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBook,
        backgroundColor: const Color(0xFF7C6AFA),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6AFA)))
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      if (_stats != null) _buildStatsRow(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('我的單字本'),
                      const SizedBox(height: 16),
                      if (_books.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                const Text('📚', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text(
                                  '還沒有單字本\n點右下角 + 新增一個吧！',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._books.map((book) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildBookCard(book),
                            )),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LinguaMastery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _email,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white38),
          tooltip: '登出',
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final total = _stats!['totalStudied'] ?? 0;
    final accuracy = _stats!['accuracy'] ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _buildStat('🔥 連續天數', '$_streak'),
          _buildDivider(),
          _buildStat('📖 今日練習', '$_todayCount'),
          _buildDivider(),
          _buildStat('📊 學習次數', '$total'),
          _buildDivider(),
          _buildStat('🎯 正確率', '${(accuracy as num).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 36, color: Colors.white12);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
    );
  }

  Widget _buildBookCard(WordBook book) {
    final isJapanese = book.language == 'JAPANESE';
    final color = isJapanese ? const Color(0xFFE53935) : const Color(0xFF3D5AFE);
    final reviewCount = _reviewCounts[book.id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 頂部：旗幟 + 書名 + ⋮ ──
          Row(
            children: [
              Text(isJapanese ? '🇯🇵' : '🇺🇸',
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(book.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Colors.white38, size: 20),
                color: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit') _editBook(book);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                        SizedBox(width: 10),
                        Text('編輯 / 刪除',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text('${book.wordCount} 個單字',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          if (book.wordCount > 0) ...[
            const SizedBox(height: 16),
            // ── 底部：四個等寬按鈕 ──
            Row(
              children: [
                _bookBtn('單字', Colors.white54, Colors.white12,
                    Colors.white24, () => _goToWordList(book)),
                const SizedBox(width: 8),
                _bookBtn('閃卡', color, color.withOpacity(0.15),
                    color.withOpacity(0.3), () => _goToStudy(book)),
                const SizedBox(width: 8),
                _bookBtn('選擇題', Colors.white54, Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.2), () => _goToQuiz(book)),
                const SizedBox(width: 8),
                _bookBtnWithBadge('複習', const Color(0xFF7C6AFA),
                    const Color(0xFF7C6AFA), reviewCount,
                    () => _goToReview(book)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookBtn(String label, Color textColor, Color bgColor,
      Color borderColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _bookBtnWithBadge(String label, Color textColor, Color accentColor,
      int badgeCount, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Color(0xFFFF5252), shape: BoxShape.circle),
                  child: Text('$badgeCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
