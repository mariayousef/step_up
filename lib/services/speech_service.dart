import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/speech_level_content.dart';

class SpeechService {
  static const String baseUrl = 'https://claribel-inescapable-ingrid.ngrok-free.dev/api';
  final Dio _dio = Dio();
  
  // Replace with actual auth token mechanism in your app
  static const String dummyToken = 'TOKEN_HERE';

  SpeechService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $dummyToken',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  Future<List<SpeechLevelContent>> getLevelContent(int levelId) async {
    try {
      final response = await _dio.get('/level/$levelId');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> listData = [];
        
        if (data is Map && data['letters'] != null) {
          listData = data['letters'];
        } else if (data is List) {
          listData = data;
        } else if (data is Map && data['data'] != null) {
          listData = data['data'];
        } else if (data is Map) {
          listData = [data]; // single object wrapped in list
        }

        return listData.map((json) => SpeechLevelContent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load level content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching level content: $e');
      return [];
    }
  }

  Future<String?> downloadReferenceAudio(String url) async {
    try {
      final directory = await getTemporaryDirectory();
      final filename = url.split('/').last;
      // In case filename is missing extension or has query params
      final path = '${directory.path}/ref_$filename';
      
      await _dio.download(url, path);
      return path;
    } catch (e) {
      print('Error downloading reference audio: $e');
      return null;
    }
  }

  Future<double> submitSpeechScore({
    required String referenceAudioPath,
    required String childAudioPath,
  }) async {
    FormData formData = FormData.fromMap({
      'reference': await MultipartFile.fromFile(referenceAudioPath),
      'child': await MultipartFile.fromFile(childAudioPath),
    });

    final response = await _dio.post(
      '/speech/score',
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      
      final rawScore = data['score'] ?? data['accuracy'] ?? 0.0;
      return double.tryParse(rawScore.toString()) ?? 0.0;
    } else {
      throw Exception('Failed to get score: ${response.statusCode} - ${response.data}');
    }
  }
}
