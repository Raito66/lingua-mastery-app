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
    if (mounted) {
      setState(() {
        _email = email;
        _books = books;
        _stats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _goToStudy(WordBook book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(book: book),
      ),
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
                                  '還沒有單字本\n請先到網頁版新增',
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
            book.wordCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      '開始測驗',
                      style: TextStyle(
                          color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                : Text('無單字', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
