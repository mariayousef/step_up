import 'package:step_up/services/api_service.dart';

class SpeechLevelContent {
  final String letter;
  final List<SpeechWord> words;

  SpeechLevelContent({
    required this.letter,
    required this.words,
  });

  // Backward compatibility getters
  String get word => words.isNotEmpty ? words[0].word : '';
  String get videoUrl => words.isNotEmpty ? words[0].videoUrl : '';
  String get videoUrl2 => words.length > 1 ? words[1].videoUrl : '';
  String get audioUrl => words.isNotEmpty ? words[0].audioUrl : '';
  String get correctImageUrl => words.isNotEmpty ? words[0].correctImageUrl : '';
  String get wrongImageUrl => words.isNotEmpty ? words[0].wrongImageUrl : '';

  factory SpeechLevelContent.fromJson(Map<String, dynamic> json) {
    var wordsList = <SpeechWord>[];
    if (json['words'] is List) {
      wordsList = (json['words'] as List)
          .map((w) => SpeechWord.fromJson(w))
          .toList();
    }

    return SpeechLevelContent(
      letter: json['letter']?.toString() ?? '',
      words: wordsList,
    );
  }
}

class SpeechWord {
  final String word;
  final String videoUrl;
  final String audioUrl;
  final String correctImageUrl;
  final String wrongImageUrl;

  SpeechWord({
    required this.word,
    required this.videoUrl,
    required this.audioUrl,
    required this.correctImageUrl,
    required this.wrongImageUrl,
  });

  factory SpeechWord.fromJson(Map<String, dynamic> json) {
    return SpeechWord(
      word: json['word']?.toString() ?? '',
      videoUrl: _fixUrl(json['video']),
      audioUrl: _fixUrl(json['audio']),
      correctImageUrl: _fixUrl(json['correct_image']),
      wrongImageUrl: _fixUrl(json['wrong_image']),
    );
  }

  static String _fixUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) return '';
    String urlStr = url.toString();
    if (!urlStr.startsWith('http')) {
      if (!urlStr.startsWith('/')) {
        urlStr = '/$urlStr';
      }
      urlStr = '${ApiService.baseUrl}$urlStr';
    }
    return urlStr.replaceAll('http://', 'https://');
  }
}
