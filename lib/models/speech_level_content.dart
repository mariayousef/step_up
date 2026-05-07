class SpeechLevelContent {
  final String letter;
  final String word;
  final String videoUrl;
  final String videoUrl2;
  final String audioUrl;
  final String correctImageUrl;
  final String wrongImageUrl;

  SpeechLevelContent({
    required this.letter,
    required this.word,
    required this.videoUrl,
    required this.videoUrl2,
    required this.audioUrl,
    required this.correctImageUrl,
    required this.wrongImageUrl,
  });

  factory SpeechLevelContent.fromJson(Map<String, dynamic> json) {
    String parsedLetter = json['letter']?.toString() ?? '';
    
    String parsedWord = '';
    String parsedVideo = '';
    String parsedVideo2 = '';
    String parsedAudio = '';
    String parsedCorrect = '';
    String parsedWrong = '';

    if (json['words'] is List && (json['words'] as List).isNotEmpty) {
      final wordsList = json['words'] as List;
      final wordObj = wordsList[0];
      if (wordObj is Map) {
        parsedWord = wordObj['word']?.toString() ?? '';
        parsedVideo = wordObj['video']?.toString().replaceAll('http://', 'https://') ?? '';
        parsedAudio = wordObj['audio']?.toString().replaceAll('http://', 'https://') ?? '';
        parsedCorrect = wordObj['correct_image']?.toString().replaceAll('http://', 'https://') ?? '';
        parsedWrong = wordObj['wrong_image']?.toString().replaceAll('http://', 'https://') ?? '';
      }
      
      if (wordsList.length > 1) {
        final wordObj2 = wordsList[1];
        if (wordObj2 is Map) {
           parsedVideo2 = wordObj2['video']?.toString().replaceAll('http://', 'https://') ?? '';
        }
      }
    }

    return SpeechLevelContent(
      letter: parsedLetter,
      word: parsedWord,
      videoUrl: parsedVideo,
      videoUrl2: parsedVideo2,
      audioUrl: parsedAudio,
      correctImageUrl: parsedCorrect,
      wrongImageUrl: parsedWrong,
    );
  }
}
