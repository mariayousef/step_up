import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => "ApiException: $message (Code: $statusCode)";
}

class ApiService {
  static const String baseUrl = "https://claribel-inescapable-ingrid.ngrok-free.dev";

  static Future<Map<String, String>> _headers({bool authorized = false}) async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "ngrok-skip-browser-warning": "true",
    };

    if (authorized) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  static dynamic _processResponse(http.Response response) {
    final body = response.body;
    final decoded = body.isNotEmpty ? jsonDecode(body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      final message = (decoded is Map) ? (decoded['message'] ?? decoded['error'] ?? 'Unknown Error') : 'Server Error';
      throw ApiException(message.toString(), response.statusCode);
    }
  }

  static Future<dynamic> getJson(String endpoint, {bool authorized = false}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _headers(authorized: authorized);
    
    print("API GET: $url");
    print("SENDING HEADERS: $headers");

    final response = await http.get(url, headers: headers);
    
    print("RAW STATUS: ${response.statusCode}");
    print("RAW BODY: ${response.body}");

    return _processResponse(response);
  }

  static Future<dynamic> postJson(String endpoint, Map<String, dynamic> body, {bool authorized = false}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _headers(authorized: authorized);

    print("API POST: $url");
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // Token & User Management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', type);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_type');
  }

  static String? extractToken(dynamic response) {
    print("EXTRACTING TOKEN FROM: $response");
    if (response is Map) {
      final token = response['token'] ?? 
                    response['access_token'] ?? 
                    (response['data'] is Map ? response['data']['token'] : null);
      
      if (token != null) {
        print("TOKEN FOUND: $token");
        return token.toString();
      }
    }
    print("TOKEN NOT FOUND IN RESPONSE");
    return null;
  }
}
