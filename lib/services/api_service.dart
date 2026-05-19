import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8080' : 'https://lingua-mastery-api.onrender.com';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  static Future<http.Response> get(String path) async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    if (res.statusCode == 401) _handleUnauthorized();
    return res;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 401) _handleUnauthorized();
    return res;
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 401) _handleUnauthorized();
    return res;
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _headers();
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: headers);
    if (res.statusCode == 401) _handleUnauthorized();
    return res;
  }
}
