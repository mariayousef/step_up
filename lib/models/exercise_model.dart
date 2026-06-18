import '../services/api_service.dart';

class Exercise {
  final int id;
  final String name;
  final String category;
  final int targetReps;
  final String videoUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetReps,
    required this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, {String category = ''}) {
    String urlStr = json['video_url']?.toString() ?? '';
    
    // Replace local server URLs with the ngrok base URL
    if (urlStr.contains('127.0.0.1:8000')) {
      urlStr = urlStr.replaceAll('http://127.0.0.1:8000', ApiService.baseUrl);
      urlStr = urlStr.replaceAll('https://127.0.0.1:8000', ApiService.baseUrl);
    } else if (urlStr.contains('localhost:8000')) {
      urlStr = urlStr.replaceAll('http://localhost:8000', ApiService.baseUrl);
      urlStr = urlStr.replaceAll('https://localhost:8000', ApiService.baseUrl);
    } else if (urlStr.isNotEmpty && !urlStr.startsWith('http')) {
      if (!urlStr.startsWith('/')) {
        urlStr = '/$urlStr';
      }
      urlStr = '${ApiService.baseUrl}$urlStr';
    }
    
    urlStr = urlStr.replaceAll('http://', 'https://');

    return Exercise(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] ?? category,
      targetReps: (json['target_reps'] as num?)?.toInt() ?? 10,
      videoUrl: urlStr,
    );
  }

  String get displayName =>
      name.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');
}

class ExerciseCategory {
  final String name;
  final List<Exercise> exercises;

  const ExerciseCategory({required this.name, required this.exercises});

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String;
    final exercises = (json['exercises'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>, category: category))
        .toList();
    return ExerciseCategory(name: category, exercises: exercises);
  }
}

class ExerciseSession {
  final String sessionId;
  final int exerciseId;
  final String status;
  final DateTime startedAt;

  const ExerciseSession({
    required this.sessionId,
    required this.exerciseId,
    required this.status,
    required this.startedAt,
  });

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      sessionId: json['session_id'].toString(),
      exerciseId: (json['exercise_id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'unknown',
      startedAt: DateTime.parse(json['started_at'] as String),
    );
  }
}

class CompletedSession {
  final String sessionId;
  final int exerciseId;
  final String status;
  final int completedReps;
  final double score;
  final String feedback;
  final DateTime startedAt;
  final DateTime completedAt;

  const CompletedSession({
    required this.sessionId,
    required this.exerciseId,
    required this.status,
    required this.completedReps,
    required this.score,
    required this.feedback,
    required this.startedAt,
    required this.completedAt,
  });

  factory CompletedSession.fromJson(Map<String, dynamic> json) {
    return CompletedSession(
      sessionId: json['session_id'].toString(),
      exerciseId: json['exercise_id'] as int,
      status: json['status'] as String,
      completedReps: json['completed_reps'] as int,
      score: (json['score'] as num).toDouble(),
      feedback: json['feedback'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }
}
