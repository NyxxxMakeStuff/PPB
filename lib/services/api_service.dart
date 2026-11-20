import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.1.5:3000/api';
    }
    return 'http://192.168.1.5:3000/api';
  }

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const _secureStorage = FlutterSecureStorage();

  static String? _memAccessToken;
  static String? _memRefreshToken;

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    _memAccessToken = accessToken;
    _memRefreshToken = refreshToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
    } catch (_) {}

    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (_) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_refreshTokenKey, refreshToken);
      } catch (_) {}
    }
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
      _memRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (_memRefreshToken != null && _memRefreshToken!.isNotEmpty) {
        return _memRefreshToken;
      }
    } catch (_) {}

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

    try {
      await _secureStorage.delete(key: _refreshTokenKey);
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

  static Future<http.Response> _authedRequest(
    Future<http.Response> Function(Map<String, String> headers) requestFn,
  ) async {
    var headers = await _headers(withAuth: true);
    var response = await requestFn(headers);

    if (response.statusCode == 401) {
      final newAccess = await refreshTokens();
      if (newAccess != null && newAccess.isNotEmpty) {
        headers = await _headers(withAuth: true);
        response = await requestFn(headers);
      }
    }
    return response;
  }

  static Future<String?> refreshTokens() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final url = Uri.parse('$baseUrl/auth/refresh');
    debugPrint('API POST refresh: $url');
    try {
      final response = await http.post(
        url,
        headers: await _headers(withAuth: false),
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _parseResponse(response);
        final session = (data is Map && data['data'] is Map) ? data['data'] as Map<String, dynamic> : (data is Map ? data : {});
        final newAccess = session['access_token']?.toString();
        final newRefresh = session['refresh_token']?.toString();
        if (newAccess != null && newRefresh != null) {
          await saveTokens(newAccess, newRefresh);
          return newAccess;
        }
      }
    } catch (_) {}
    await clearTokens();
    return null;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    debugPrint('API POST login: $url');
    final response = await http.post(
      url,
      headers: await _headers(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _parseResponse(response);
    final session = (data is Map && data['data'] is Map) ? data['data'] as Map<String, dynamic> : (data is Map ? data : {});
    final accessToken = session['access_token'] ?? session['accessToken'];
    final refreshToken = session['refresh_token'] ?? session['refreshToken'];

    if (accessToken != null) {
      await saveTokens(accessToken.toString(), refreshToken?.toString() ?? '');
    }
    return data is Map<String, dynamic> ? data : {};
  }

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    String? jenisKelamin = 'L',
    String? tanggalLahir = '1995-05-12',
    double? tinggiCm = 172.0,
    String? levelAktivitas = 'moderate',
    String? tujuan = 'maintain',
    int? targetKalori = 2600,
    double? targetProtein = 130.0,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    debugPrint('API POST register: $url');
    final Map<String, dynamic> body = {
      'nama': nama.trim().isNotEmpty ? nama.trim() : 'Pengguna',
      'email': email,
      'password': password,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'tinggi_cm': tinggiCm,
      'level_aktivitas': levelAktivitas,
      'tujuan': tujuan,
      'target_kalori': targetKalori,
      'target_protein': targetProtein,
    };

    final response = await http.post(
      url,
      headers: await _headers(withAuth: false),
      body: jsonEncode(body),
    );

    final data = _parseResponse(response);
    final session = (data is Map && data['data'] is Map) ? data['data'] as Map<String, dynamic> : (data is Map ? data : {});
    final accessToken = session['access_token'] ?? session['accessToken'];
    final refreshToken = session['refresh_token'] ?? session['refreshToken'];

    if (accessToken != null) {
      await saveTokens(accessToken.toString(), refreshToken?.toString() ?? '');
    }
    return data is Map<String, dynamic> ? data : {};
  }

  static Future<Map<String, dynamic>> getMe() async {
    final url = Uri.parse('$baseUrl/auth/me');
    debugPrint('API GET me: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    return _parseResponse(response);
  }

  static Future<void> logout() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final url = Uri.parse('$baseUrl/auth/logout');
        debugPrint('API POST logout: $url');
        await http.post(
          url,
          headers: await _headers(withAuth: true),
          body: jsonEncode({'refresh_token': refreshToken}),
        );
      } catch (_) {}
    }
    await clearTokens();
  }

  static Future<Map<String, dynamic>> updateUserProfile(int userId, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    debugPrint('API PATCH users/$userId: $url');
    final response = await _authedRequest(
      (headers) => http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> logBodyWeight(int userId, double weightKg, String dateStr) async {
    final url = Uri.parse('$baseUrl/body_weight_logs');
    debugPrint('API POST body_weight_logs: $url');
    final response = await _authedRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'tanggal': dateStr,
          'berat_kg': weightKg,
        }),
      ),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getBodyWeightLogs() async {
    final url = Uri.parse('$baseUrl/body_weight_logs');
    debugPrint('API GET body_weight_logs: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  static Future<List<dynamic>> getWorkoutLogs() async {
    final url = Uri.parse('$baseUrl/workout_logs');
    debugPrint('API GET workout_logs: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> createWorkoutLog(
    int userId,
    String tanggal,
    int durasiMenit, {
    double totalKaloriTerbakar = 100.0,
    String? catatan,
  }) async {
    final url = Uri.parse('$baseUrl/workout_logs');
    debugPrint('API POST workout_logs: $url');
    final Map<String, dynamic> body = {
      'user_id': userId,
      'tanggal': tanggal,
      'total_durasi_menit': durasiMenit,
      'total_kalori_terbakar': totalKaloriTerbakar,
    };
    if (catatan != null) body['catatan'] = catatan;

    final response = await _authedRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getNutritionLogs() async {
    final url = Uri.parse('$baseUrl/nutrition_logs');
    debugPrint('API GET nutrition_logs: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> createNutritionLog(
    int userId,
    String tanggal,
    String waktuMakan,
  ) async {
    final url = Uri.parse('$baseUrl/nutrition_logs');
    debugPrint('API POST nutrition_logs: $url');
    final response = await _authedRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'tanggal': tanggal,
          'waktu_makan': waktuMakan,
        }),
      ),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getNutritionLogItems() async {
    final url = Uri.parse('$baseUrl/nutrition_log_items');
    debugPrint('API GET nutrition_log_items: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  static Future<Map<String, dynamic>> createNutritionLogItem(
    int nutritionLogId,
    int foodId,
    double jumlahGram,
    double kalori,
    double proteinG, {
    double carbsG = 0.0,
    double fatG = 0.0,
  }) async {
    final url = Uri.parse('$baseUrl/nutrition_log_items');
    debugPrint('API POST nutrition_log_items: $url');
    final response = await _authedRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'nutrition_log_id': nutritionLogId,
          'food_id': foodId,
          'jumlah_gram': jumlahGram,
          'kalori': kalori,
          'protein_g': proteinG,
          'karbo_g': carbsG,
          'lemak_g': fatG,
        }),
      ),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getFoods() async {
    final url = Uri.parse('$baseUrl/foods');
    debugPrint('API GET foods: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  static Future<List<dynamic>> getExercises() async {
    final url = Uri.parse('$baseUrl/exercises');
    debugPrint('API GET exercises: $url');
    final response = await _authedRequest((headers) => http.get(url, headers: headers));
    final data = _parseResponse(response);
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  static dynamic _parseResponse(http.Response response) {
    debugPrint('API Response (${response.statusCode}): ${response.body}');
    if (response.statusCode == 204 || response.body.trim().isEmpty) {
      return {};
    }

    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody ?? {};
    }

    String message = 'Terjadi kesalahan pada server (${response.statusCode})';
    if (jsonBody is Map) {
      if (jsonBody['error'] != null) {
        message = jsonBody['error'].toString();
        if (jsonBody['details'] is List && (jsonBody['details'] as List).isNotEmpty) {
          final issues = (jsonBody['details'] as List)
              .map((d) => d is Map && d['message'] != null ? d['message'].toString() : null)
              .whereType<String>()
              .toList();
          if (issues.isNotEmpty) {
            message = '$message (${issues.join(', ')})';
          }
        }
      } else if (jsonBody['message'] != null) {
        message = jsonBody['message'].toString();
      }
    }
    throw ApiException(message, response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
