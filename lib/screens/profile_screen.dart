import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthService.getProfile();
      if (mounted) setState(() { _profile = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('載入個人資料失敗，請稍後再試')),
      );
      Navigator.pop(context);
    }
  }

  String _initials(String? displayName, String email) {
    final base = (displayName?.isNotEmpty == true ? displayName! : email);
    final part = base.split(RegExp(r'[@\s]+')).first;
    if (part.isEmpty) return '?';
    return (part.length >= 2 ? part.substring(0, 2) : part).toUpperCase();
  }

  Future<void> _editDisplayName() async {
    final ctrl = TextEditingController(text: _profile?.displayName ?? '');
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('編輯顯示名稱', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                maxLength: 50,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '輸入顯示名稱',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterStyle: const TextStyle(color: Colors.white38),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 4),
                Text(error!, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => error = '顯示名稱不能為空');
                  return;
                }
                final err = await AuthService.updateProfile(name);
                if (!context.mounted) return;
                if (err != null) {
                  setDialogState(() => error = err);
                } else {
                  Navigator.pop(ctx);
                  _loadProfile();
                }
              },
              child: const Text('儲存', style: TextStyle(color: Color(0xFF7C6AFA))),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    bool showCurrent = false;
    bool showNew = false;
    String? error;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('更改密碼', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: !showCurrent,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '目前密碼',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showCurrent ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38, size: 20,
                    ),
                    onPressed: () => setDialogState(() => showCurrent = !showCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: !showNew,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '新密碼（8碼以上，含英文與數字）',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNew ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38, size: 20,
                    ),
                    onPressed: () => setDialogState(() => showNew = !showNew),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: saving
                  ? null
                  : () async {
                      final cur = currentCtrl.text;
                      final nw = newCtrl.text;
                      final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
                      if (!regex.hasMatch(nw)) {
                        setDialogState(() => error = '新密碼至少 8 碼，須包含英文字母與數字');
                        return;
                      }
                      setDialogState(() { saving = true; error = null; });
                      final err = await AuthService.changePassword(cur, nw);
                      if (!context.mounted) return;
                      if (err != null) {
                        setDialogState(() { saving = false; error = err; });
                      } else {
                        Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('密碼已更新')),
                          );
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C6AFA)),
                    )
                  : const Text('確認更改', style: TextStyle(color: Color(0xFF7C6AFA))),
            ),
          ],
        ),
      ),
    );
    currentCtrl.dispose();
    newCtrl.dispose();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('會員專區',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6AFA)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Avatar + name
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C6AFA),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(_profile?.displayName, _profile?.email ?? ''),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _profile?.displayName?.isNotEmpty == true
                                ? _profile!.displayName!
                                : '（未設定顯示名稱）',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profile?.email ?? '',
                            style: const TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _editDisplayName,
                            child: const Text('編輯顯示名稱',
                                style: TextStyle(color: Color(0xFF7C6AFA), fontSize: 13)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Settings
                    _settingTile(
                      icon: Icons.lock_outline_rounded,
                      label: '更改密碼',
                      onTap: _changePassword,
                    ),

                    const SizedBox(height: 16),

                    // About
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('關於',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1)),
                          const SizedBox(height: 16),
                          _aboutRow('製作者', '萊特 Light'),
                          const SizedBox(height: 10),
                          _aboutRow('GitHub', 'github.com/Raito66'),
                          const SizedBox(height: 10),
                          _aboutRow('Email', 'tfy4942@gmail.com'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5252),
                          side: const BorderSide(color: Color(0xFFFF5252), width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('登出',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }
}
