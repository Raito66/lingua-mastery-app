import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? successMessage;

  const LoginScreen({super.key, this.successMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _emailNotVerified = false;
  bool _resending = false;
  String? _resendMsg;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _emailNotVerified = false;
      _resendMsg = null;
    });
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (_isLogin) {
      final msg = await AuthService.loginWithMessage(email, password);
      if (!mounted) return;
      if (msg == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (msg == 'EMAIL_NOT_VERIFIED') {
        setState(() { _emailNotVerified = true; _loading = false; });
      } else {
        setState(() { _error = 'Email 或密碼錯誤'; _loading = false; });
      }
    } else {
      final err = await AuthService.register(email, password);
      if (!mounted) return;
      if (err == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
        );
      } else {
        setState(() { _error = err; _loading = false; });
      }
    }
  }

  Future<void> _resendVerification() async {
    setState(() { _resending = true; _resendMsg = null; });
    final err = await AuthService.resendVerification(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _resendMsg = err == null ? '驗證信已重新寄出，請查收信箱' : err;
      _resending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📚', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const Text(
                  'LinguaMastery',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLogin ? '登入帳號' : '建立帳號',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                if (widget.successMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.successMessage!,
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: _inputDecoration('密碼'),
                ),
                const SizedBox(height: 12),

                // Email 未驗證提示框
                if (_emailNotVerified)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email 尚未驗證',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('請查收 ${_emailCtrl.text.trim()} 的驗證信',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _resending ? null : _resendVerification,
                          child: Text(
                            _resending ? '寄送中...' : '重新寄送驗證信',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        if (_resendMsg != null) ...[
                          const SizedBox(height: 4),
                          Text(_resendMsg!,
                              style: const TextStyle(fontSize: 12, color: Colors.green)),
                        ],
                      ],
                    ),
                  ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_isLogin ? '登入' : '建立帳號'),
                  ),
                ),

                // 忘記密碼（僅登入模式）
                if (_isLogin)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text('忘記密碼？',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),

                TextButton(
                  onPressed: () => setState(() {
                    _isLogin = !_isLogin;
                    _error = null;
                    _emailNotVerified = false;
                    _resendMsg = null;
                  }),
                  child: Text(
                    _isLogin ? '還沒有帳號？註冊' : '已有帳號？登入',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
