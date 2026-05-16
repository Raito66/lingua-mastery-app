import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_book.dart';
import '../services/word_service.dart';
import '../services/auth_service.dart';
import 'flashcard_screen.dart';
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
    final books = await WordService.getBooks();
    final stats = await WordService.getStats();
    final reviewCounts = await WordService.getReviewStats();
    if (mounted) {
      setState(() {
        _email = email;
        _books = books;
        _stats = stats;
        _reviewCounts = reviewCounts;
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

  Future<void> _goToStudy(WordBook book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlashcardScreen(book: book)),
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
    final correct = _stats!['totalCorrect'] ?? 0;
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
          _buildStat('📊 學習次數', '$total'),
          _buildDivider(),
          _buildStat('✅ 答對', '$correct'),
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

    return GestureDetector(
      onTap: book.wordCount > 0 ? () => _goToStudy(book) : null,
      onLongPress: () => _editBook(book),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(isJapanese ? '🇯🇵' : '🇺🇸',
                style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${book.wordCount} 個單字',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (book.wordCount > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _goToStudy(book),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text('測驗',
                          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _goToReview(book),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C6AFA).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF7C6AFA).withOpacity(0.3)),
                          ),
                          child: const Text('複習',
                              style: TextStyle(
                                  color: Color(0xFF7C6AFA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if ((_reviewCounts[book.id] ?? 0) > 0)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5252),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_reviewCounts[book.id]}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Text('無單字', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
