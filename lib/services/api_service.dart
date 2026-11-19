import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    // For real physical phone via USB, run `adb reverse tcp:3000 tcp:3000` in terminal
    // Then localhost:3000 works on the physical phone!
    // If not using adb reverse, replace 'localhost' with your PC's Wi-Fi IP (e.g. '192.168.1.x:3000')
    if (!kIsWeb && Platform.isAndroid) {
      // If using emulator, use 10.0.2.2:3000. If using real phone with adb reverse, use localhost:3000
      // Change this to your PC's Wi-Fi IP if adb reverse is not used (e.g. 'http://192.168.1.15:3000/api')
      return 'http://localhost:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static String? _memAccessToken;
  static String? _memRefreshToken;

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    _memAccessToken = accessToken;
    _memRefreshToken = refreshToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (_) {}
  }

  static Future<String?> getAccessToken() async {
    if (_memAccessToken != null) return _memAccessToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _memAccessToken = prefs.getString(_accessTokenKey);
      return _memAccessToken;
    } catch (_) {
      return _memAccessToken;
    }
  }

  static Future<String?> getRefreshToken() async {
    if (_memRefreshToken != null) return _memRefreshToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _memRefreshToken = prefs.getString(_refreshTokenKey);
      return _memRefreshToken;
    } catch (_) {
      return _memRefreshToken;
    }
  }

  static Future<void> clearTokens() async {
    _memAccessToken = null;
    _memRefreshToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {}
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    debugPrint('API POST: $url');
    final response = await http.post(
      url,
      headers: await _headers(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _parseResponse(response);
    final accessToken = data['access_token'] ?? data['accessToken'] ?? data['data']?['access_token'];
    final refreshToken = data['refresh_token'] ?? data['refreshToken'] ?? data['data']?['refresh_token'];
    
    if (accessToken != null) {
      await saveTokens(accessToken.toString(), refreshToken?.toString() ?? '');
    }
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    debugPrint('API POST: $url');
    final response = await http.post(
      url,
      headers: await _headers(withAuth: false),
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'password': password,
        'jenis_kelamin': 'L',
        'tanggal_lahir': '1995-01-01',
        'tinggi_cm': 172,
        'level_aktivitas': 'moderate',
        'tujuan': 'maintain',
        'target_kalori': 2600,
        'target_protein': 130,
      }),
    );

    final data = _parseResponse(response);
    final accessToken = data['access_token'] ?? data['accessToken'] ?? data['data']?['access_token'];
    final refreshToken = data['refresh_token'] ?? data['refreshToken'] ?? data['data']?['refresh_token'];

    if (accessToken != null) {
      await saveTokens(accessToken.toString(), refreshToken?.toString() ?? '');
    }
    return data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final url = Uri.parse('$baseUrl/auth/me');
    debugPrint('API GET: $url');
    final response = await http.get(
      url,
      headers: await _headers(withAuth: true),
    );
    return _parseResponse(response);
  }

  static Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/auth/logout');
      debugPrint('API POST: $url');
      await http.post(url, headers: await _headers(withAuth: true));
    } catch (_) {}
    await clearTokens();
  }

  static Future<Map<String, dynamic>> updateUserProfile(int userId, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    debugPrint('API PATCH: $url');
    final response = await http.patch(
      url,
      headers: await _headers(withAuth: true),
      body: jsonEncode(body),
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> logBodyWeight(double weightKg, String dateStr) async {
    final url = Uri.parse('$baseUrl/body_weight_logs');
    debugPrint('API POST: $url');
    final response = await http.post(
      url,
      headers: await _headers(withAuth: true),
      body: jsonEncode({
        'berat_kg': weightKg,
        'tanggal': dateStr,
      }),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getWorkoutLogs() async {
    final url = Uri.parse('$baseUrl/workout_logs');
    debugPrint('API GET: $url');
    final response = await http.get(
      url,
      headers: await _headers(withAuth: true),
    );
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> createWorkoutLog({
    required String tanggal,
    required int durasiMenit,
    String? catatan,
  }) async {
    final url = Uri.parse('$baseUrl/workout_logs');
    debugPrint('API POST: $url');
    final Map<String, dynamic> body = {
      'tanggal': tanggal,
      'durasi_menit': durasiMenit,
    };
    if (catatan != null) body['catatan'] = catatan;

    final response = await http.post(
      url,
      headers: await _headers(withAuth: true),
      body: jsonEncode(body),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getNutritionLogs() async {
    final url = Uri.parse('$baseUrl/nutrition_logs');
    debugPrint('API GET: $url');
    final response = await http.get(
      url,
      headers: await _headers(withAuth: true),
    );
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> createNutritionLog({
    required String tanggal,
    required String waktuMakan,
    required int totalKalori,
    required int totalProtein,
  }) async {
    final url = Uri.parse('$baseUrl/nutrition_logs');
    debugPrint('API POST: $url');
    final response = await http.post(
      url,
      headers: await _headers(withAuth: true),
      body: jsonEncode({
        'tanggal': tanggal,
        'waktu_makan': waktuMakan,
        'total_kalori': totalKalori,
        'total_protein': totalProtein,
      }),
    );
    return _parseResponse(response);
  }

  static dynamic _parseResponse(http.Response response) {
    debugPrint('API Response (${response.statusCode}): ${response.body}');
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody ?? {};
    }

    final message = jsonBody is Map
        ? (jsonBody['message'] ?? jsonBody['error'] ?? 'Terjadi kesalahan pada server (${response.statusCode})')
        : 'Terjadi kesalahan pada server (${response.statusCode})';
    throw ApiException(message.toString(), response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
