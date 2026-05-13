import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/speech_level_content.dart';
import 'api_service.dart';

class SpeechService {
  static const String baseUrl = 'https://claribel-inescapable-ingrid.ngrok-free.dev/api';
  final Dio _dio = Dio();

  SpeechService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ApiService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<SpeechLevelContent>> getLevelContent(int levelId) async {
    try {
      final response = await _dio.get('/level/$levelId');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> listData = [];
        
        if (data is Map) {
          if (data['data'] != null && data['data'] is Map && data['data']['letters'] != null) {
            listData = data['data']['letters'];
          } else if (data['letters'] != null) {
            listData = data['letters'];
          } else if (data['data'] != null && data['data'] is List) {
            listData = data['data'];
          } else {
            listData = [data];
          }
        } else if (data is List) {
          listData = data;
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

  Future<SpeechScoreResponse> submitSpeechScore({
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
      
      final resultData = data['data'] ?? data;
      return SpeechScoreResponse.fromJson(resultData);
    } else {
      throw Exception('Failed to get score: ${response.statusCode} - ${response.data}');
    }
  }
}

class SpeechScoreResponse {
  final double score;
  final String label;
  final double similarity;
  final double refDuration;
  final double childDuration;

  SpeechScoreResponse({
    required this.score,
    required this.label,
    required this.similarity,
    required this.refDuration,
    required this.childDuration,
  });

  factory SpeechScoreResponse.fromJson(Map<String, dynamic> json) {
    return SpeechScoreResponse(
      score: _toDouble(json['score']),
      label: json['label']?.toString() ?? '',
      similarity: _toDouble(json['similarity']),
      refDuration: _toDouble(json['ref_duration']),
      childDuration: _toDouble(json['child_duration']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
