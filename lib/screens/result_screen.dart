import 'package:flutter/material.dart';
import '../models/word_book.dart';
import 'home_screen.dart';
import 'flashcard_screen.dart';

class ResultScreen extends StatelessWidget {
  final WordBook? book;
  final String language;
  final String level;
  final int total;
  final int knownCount;
  final int dontKnowCount;
  final int xpGained;

  const ResultScreen({
    super.key,
    this.book,
    required this.language,
    required this.level,
    required this.total,
    required this.knownCount,
    required this.dontKnowCount,
    required this.xpGained,
  });

  double get _accuracy => total == 0 ? 0 : knownCount / total;

  String get _grade {
    if (_accuracy >= 0.9) return 'S';
    if (_accuracy >= 0.7) return 'A';
    if (_accuracy >= 0.5) return 'B';
    if (_accuracy >= 0.3) return 'C';
    return 'D';
  }

  Color get _gradeColor {
    if (_accuracy >= 0.9) return const Color(0xFFFFD700);
    if (_accuracy >= 0.7) return const Color(0xFF69F0AE);
    if (_accuracy >= 0.5) return const Color(0xFF7C6AFA);
    if (_accuracy >= 0.3) return const Color(0xFFFFB300);
    return const Color(0xFFFF5252);
  }

  String get _encouragement {
    if (_accuracy >= 0.9) return '完美！你是語言天才！🏆';
    if (_accuracy >= 0.7) return '太棒了！繼續保持！🎉';
    if (_accuracy >= 0.5) return '不錯喔！再努力一下！💪';
    if (_accuracy >= 0.3) return '繼續加油！熟能生巧！📚';
    return '沒關係，多練習就會了！🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── 評等圓圈 ──
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gradeColor.withOpacity(0.1),
                  border: Border.all(color: _gradeColor, width: 3),
                  boxShadow: [
                    BoxShadow(color: _gradeColor.withOpacity(0.3), blurRadius: 24),
                  ],
                ),
                child: Center(
                  child: Text(
                    _grade,
                    style: TextStyle(
                      color: _gradeColor,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _encouragement,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── 統計卡片 ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _buildStatRow('✅ 答對', '$knownCount 個', const Color(0xFF69F0AE)),
                    const SizedBox(height: 12),
                    _buildStatRow('❌ 還需加強', '$dontKnowCount 個', const Color(0xFFFF5252)),
                    const SizedBox(height: 12),
                    _buildStatRow('📊 正確率', '${(_accuracy * 100).toStringAsFixed(0)}%', Colors.white70),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white12),
                    ),
                    _buildStatRow('⚡ 獲得 XP', '+$xpGained', const Color(0xFFFFD700)),
                  ],
                ),
              ),
              const Spacer(),

              // ── 按鈕區 ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('回首頁'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: book == null
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FlashcardScreen(book: book!),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6AFA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('再練一次 🔄', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Text(value,
            style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
