import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api/auth";
  // لو iOS Emulator:
  // static const String baseUrl = "http://127.0.0.1:8000/api/auth";

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        print("Login success: ${response.body}");
        return true;
      } else {
        print("Login failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Register success: ${response.body}");
        return true;
      } else {
        print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }
}
