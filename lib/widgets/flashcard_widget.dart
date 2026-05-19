import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/word.dart';

class FlashcardWidget extends StatefulWidget {
  final Word word;
  final VoidCallback onKnow;
  final VoidCallback onDontKnow;
  final VoidCallback? onSpeak;

  const FlashcardWidget({
    super.key,
    required this.word,
    required this.onKnow,
    required this.onDontKnow,
    this.onSpeak,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 提示文字 ──
        AnimatedOpacity(
          opacity: _showFront ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: const Text(
            '點擊卡片翻面查看翻譯',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),

        // ── 翻牌卡片 ──
        GestureDetector(
          onTap: _flip,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value;
              final isFrontVisible = angle < math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isFrontVisible
                    ? _CardFace(word: widget.word, isFront: true, onSpeak: widget.onSpeak)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _CardFace(word: widget.word, isFront: false),
                      ),
              );
            },
          ),
        ),

        const SizedBox(height: 28),

        // ── 知道 / 不知道 按鈕 ──
        AnimatedOpacity(
          opacity: _showFront ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: _showFront,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: '還不會',
                  icon: Icons.close_rounded,
                  color: const Color(0xFFFF5252),
                  onTap: widget.onDontKnow,
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  label: '我會了！',
                  icon: Icons.check_rounded,
                  color: const Color(0xFF69F0AE),
                  onTap: widget.onKnow,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────
// 卡片正面 / 背面
// ────────────────────────────────────────────────
class _CardFace extends StatelessWidget {
  final Word word;
  final bool isFront;
  final VoidCallback? onSpeak;

  const _CardFace({required this.word, required this.isFront, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFront
              ? [const Color(0xFF2D2B55), const Color(0xFF1A1A3E)]
              : [const Color(0xFF1B4332), const Color(0xFF0D2B1E)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFront
              ? const Color(0xFF7C6AFA).withOpacity(0.4)
              : const Color(0xFF69F0AE).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFront ? const Color(0xFF7C6AFA) : const Color(0xFF69F0AE))
                .withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isFront ? _buildFront() : _buildBack(),
    );
  }

  ({String label, Color color}) _proficiencyBadge(int level) {
    switch (level) {
      case 3: return (label: '已精通', color: const Color(0xFFCE93D8));
      case 2: return (label: '已熟悉', color: const Color(0xFF69F0AE));
      case 1: return (label: '學習中', color: const Color(0xFFFFD54F));
      default: return (label: '未學習', color: Colors.white38);
    }
  }

  Widget _buildFront() {
    final isJapanese = word.language == 'japanese';
    final profBadge = _proficiencyBadge(word.proficiencyLevel);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 語言標籤 + 熟練度徽章
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6AFA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7C6AFA).withOpacity(0.5)),
                ),
                child: Text(
                  isJapanese ? '🇯🇵 日文' : '🇺🇸 英文',
                  style: const TextStyle(color: Color(0xFF7C6AFA), fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: profBadge.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: profBadge.color.withOpacity(0.5)),
                ),
                child: Text(
                  profBadge.label,
                  style: TextStyle(color: profBadge.color, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 單字
          Text(
            word.word,
            style: TextStyle(
              color: Colors.white,
              fontSize: isJapanese ? 44 : 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (isJapanese && word.reading.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.reading,
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
          if (isJapanese && word.romaji.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.romaji,
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          if (onSpeak != null)
            GestureDetector(
              onTap: onSpeak,
              child: const Icon(Icons.volume_up_rounded, color: Colors.white38, size: 28),
            )
          else
            const Icon(Icons.touch_app_rounded, color: Colors.white24, size: 28),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 翻譯
          const Text('翻譯', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            word.translation,
            style: const TextStyle(
              color: Color(0xFF69F0AE),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // 例句
          const Text('例句', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            word.example,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
          if (word.exampleTranslation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              word.exampleTranslation,
              style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// 知道 / 不知道 按鈕
// ────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
