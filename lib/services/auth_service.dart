import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ProfileData {
  final String email;
  final String? displayName;

  ProfileData({required this.email, this.displayName});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }
}

class AuthService {
  static Future<bool> login(String email, String password) async {
    final res = await ApiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('email', data['email']);
      return true;
    }
    return false;
  }

  /// null = 登入成功並已存 token；'EMAIL_NOT_VERIFIED' = 未驗證；其他字串 = 錯誤
  static Future<String?> loginWithMessage(String email, String password) async {
    final res = await ApiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('email', data['email']);
      return null;
    }
    final data = jsonDecode(res.body);
    return data['message'] ?? 'ERROR';
  }

  /// null = 成功（需驗證信），字串 = 錯誤訊息
  static Future<String?> register(String email, String password, String displayName) async {
    final res = await ApiService.post('/api/auth/register', {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    if (res.statusCode == 200) return null;
    final data = jsonDecode(res.body);
    return data['message'] ?? '註冊失敗';
  }

  /// 回傳 'EMAIL_NOT_VERIFIED' 表示未驗證，null 表示其他錯誤
  static Future<String?> loginErrorMessage(String email, String password) async {
    final res = await ApiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) return 'OK';
    final data = jsonDecode(res.body);
    return data['message'] ?? 'ERROR';
  }

  static Future<String?> forgotPassword(String email) async {
    final res = await ApiService.post('/api/auth/forgot-password', {'email': email});
    if (res.statusCode == 200) return null;
    final data = jsonDecode(res.body);
    return data['message'] ?? '發生錯誤';
  }

  static Future<String?> resetPassword(String token, String password) async {
    final res = await ApiService.post('/api/auth/reset-password', {
      'token': token,
      'password': password,
    });
    if (res.statusCode == 200) return null;
    final data = jsonDecode(res.body);
    return data['message'] ?? '重設失敗';
  }

  static Future<String?> resendVerification(String email) async {
    final res = await ApiService.post('/api/auth/resend-verification', {'email': email});
    if (res.statusCode == 200) return null;
    final data = jsonDecode(res.body);
    return data['message'] ?? '發生錯誤';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  static Future<ProfileData> getProfile() async {
    final res = await ApiService.get('/api/profile');
    if (res.statusCode == 200) {
      return ProfileData.fromJson(jsonDecode(res.body));
    }
    throw Exception('載入個人資料失敗 (${res.statusCode})');
  }

  /// null = 成功，字串 = 錯誤訊息
  static Future<String?> updateProfile(String displayName) async {
    final res = await ApiService.put('/api/profile', {'displayName': displayName});
    if (res.statusCode == 200) return null;
    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    return data['message'] as String? ?? '更新失敗';
  }

  /// null = 成功，字串 = 錯誤訊息
  static Future<String?> changePassword(String currentPassword, String newPassword) async {
    final res = await ApiService.put('/api/profile/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (res.statusCode == 200) return null;
    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    return data['message'] as String? ?? '更改失敗';
  }
}
