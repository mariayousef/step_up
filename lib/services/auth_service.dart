import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_request_model.dart';

class AuthService {
  static const String baseUrl =
      "https://claribel-inescapable-ingrid.ngrok-free.dev/api/auth";

  Future<bool> registerParentAndChild(RegisterRequestModel data) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data.toJson()),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }
  Future<bool> login(String email, String password) async {
    final url = Uri.parse(
      "https://claribel-inescapable-ingrid.ngrok-free.dev/api/auth/login",
    );

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

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

}
