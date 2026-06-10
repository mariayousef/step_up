import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class BodyTrainingService {
  final String baseUrl;
  final String apiKey;
  final String webhookUrl;
  
  WebSocketChannel? _channel;
  String? _currentSessionId;
  
  // Stream controller to broadcast frame results to the UI
  final _resultController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get resultStream => _resultController.stream;

  BodyTrainingService({
    required this.baseUrl,
    required this.apiKey,
    this.webhookUrl = 'https://your-backend.com/webhooks/session',
  });

  // Health Check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Start Session
  Future<String?> startSession(String userId, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode({
          'user_id': userId,
          'language': language,
          'webhook_url': webhookUrl,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _currentSessionId = data['session_id'];
        return _currentSessionId;
      } else {
        print('Failed to start session: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error starting session: $e');
      return null;
    }
  }

  // Connect WebSocket
  void connectWebSocket(String sessionId) {
    final wsUrl = baseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl/ws/$sessionId?api_key=$apiKey');
    
    _channel = WebSocketChannel.connect(uri);
    
    _channel?.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        _resultController.add(data);
      } catch (e) {
        print('Error parsing websocket message: $e');
      }
    }, onError: (error) {
      print('WebSocket Error: $error');
      _resultController.add({"type": "error", "message": error.toString()});
    }, onDone: () {
      print('WebSocket connection closed');
      _resultController.add({"type": "closed", "message": "WebSocket closed"});
    });
  }

  // Send Frame Binary
  void sendFrameAsBinary(Uint8List bytes) {
    if (_channel != null) {
      _channel?.sink.add(bytes);
    }
  }

  // Send Reset Command
  void sendReset() {
    if (_channel != null) {
      _channel?.sink.add(jsonEncode({
        "type": "reset"
      }));
    }
  }

  // End Session
  Future<Map<String, dynamic>?> endSession() async {
    if (_channel != null) {
      _channel?.sink.add(jsonEncode({"type": "end_session"}));
    }

    Map<String, dynamic>? sessionSummary;

    if (_currentSessionId != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/sessions/$_currentSessionId/end'),
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': apiKey,
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 || response.statusCode == 201) {
          sessionSummary = jsonDecode(response.body);
        }
      } catch (e) {
        print('Error ending session: $e');
      }
      _currentSessionId = null;
    }
    
    _channel?.sink.close();
    _channel = null;
    
    return sessionSummary;
  }
  
  // Dispose
  void dispose() {
    endSession();
    _resultController.close();
  }
}
