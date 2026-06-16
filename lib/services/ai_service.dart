import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:step_up/config/ai_config.dart';

class AiService {
  static Future<String> startAiSession({
    required String userId,
    required int exerciseId,
    required int targetReps,
    String difficulty = "medium",
    String language = "ar",
    String mode = "locked",
  }) async {
    final url = Uri.parse('${AiConfig.restBaseUrl}/sessions');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': AiConfig.apiKey,
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "user_id": userId,
        "exercise_id": exerciseId,
        "difficulty": difficulty,
        "target_reps": targetReps,
        "language": language,
        "mode": mode,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return decoded['session_id'].toString();
    } else {
      throw Exception('Failed to start AI session: ${response.statusCode} - ${response.body}');
    }
  }
}
