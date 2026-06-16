import 'package:step_up/models/exercise_model.dart';
import 'package:step_up/services/api_service.dart';

class ExerciseService {
  static const String _exercisesEndpoint = '/api/exercises';
  static const String _sessionsEndpoint = '/api/exercise-sessions';

  // ─── Get All Exercises (grouped by category) ───────────────────────────────
  static Future<List<ExerciseCategory>> getExercises() async {
    try {
      final response = await ApiService.getJson(_exercisesEndpoint);
      final data = response['data'] as List<dynamic>;
      return data
          .map((e) => ExerciseCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  // ─── Get Single Exercise ────────────────────────────────────────────────────
  static Future<Exercise> getExercise(int id) async {
    try {
      final response = await ApiService.getJson('$_exercisesEndpoint/$id');
      return Exercise.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch exercise: $e');
    }
  }

  // ─── Start Exercise Session (Main Backend) ──────────────────────────────────
  static Future<int> startSession(int exerciseId, int targetReps) async {
    try {
      final response = await ApiService.postJson(
        _sessionsEndpoint,
        {
          'exercise_id': exerciseId,
        },
      );
      final data = response['data'];
      final rawId = data['session_id'] ?? data['id'];
      if (rawId == null) {
        throw Exception(
          'Backend response missing session ID. Response data: $data',
        );
      }
      return rawId is int ? rawId : int.parse(rawId.toString());
    } catch (e) {
      throw Exception('Failed to start exercise session on main backend: $e');
    }
  }

  // ─── Complete Exercise Session ──────────────────────────────────────────────
  static Future<CompletedSession> completeSession({
    required int sessionId,
    required int completedReps,
    required double score,
    required String feedback,
  }) async {
    try {
      final response = await ApiService.postJson(
        '$_sessionsEndpoint/$sessionId/complete',
        {
          'completed_reps': completedReps,
          'score': score,
          'feedback': feedback,
        },
      );
      return CompletedSession.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to complete exercise session: $e');
    }
  }
}
