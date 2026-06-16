import 'package:flutter/foundation.dart';
import 'package:step_up/models/progress_model.dart';
import 'package:step_up/services/api_service.dart';

class ProgressService {
  /// Holds the latest weekly progress for the currently logged in parent/child.
  static final ValueNotifier<ProgressData?> currentProgress = ValueNotifier(null);

  /// Fetch progress data for a given period: 'week', 'month', or 'year'
  static Future<ProgressData> getProgress(String period, {String? parentId}) async {
    try {
      String url = '/api/progress?period=$period';
      if (parentId != null && parentId.isNotEmpty) {
        url += '&parent_id=$parentId';
      }
      
      final response = await ApiService.getJson(
        url,
        authorized: true,
      );
      final data = response['data'] as Map<String, dynamic>;
      var progress = ProgressData.fromJson(data);

      // --- MOCK DATA FOR DOCTOR IF API RETURNS 0 ---
      // Hardcoded to match the parent's view as requested for prototype
      if (parentId != null && progress.overallProgress == 0) {
        progress = const ProgressData(
          overallProgress: 17,
          speechProgress: 25,
          bodyProgress: 8,
          message: "Keep training | you can improve",
          period: 'week',
          chart: [],
        );
      }

      // Update the global notifier if it's the weekly progress for the logged-in user
      if (period == 'week' && (parentId == null || parentId.isEmpty)) {
        currentProgress.value = progress;
      }

      return progress;
    } catch (e) {
      // If the API call fails, still return the mock data if requested for a specific parent
      if (parentId != null && parentId.isNotEmpty) {
        return const ProgressData(
          overallProgress: 17,
          speechProgress: 25,
          bodyProgress: 8,
          message: "Keep training | you can improve",
          period: 'week',
          chart: [],
        );
      }
      throw Exception('Failed to fetch progress: $e');
    }
  }

  /// Save body training score after an exercise.
  ///
  /// You can either provide [correctReps] + [totalReps] (the backend calculates %),
  /// or provide [score] directly (0–100).
  static Future<int> saveBodyTrainingScore({
    required String exerciseName,
    int? correctReps,
    int? totalReps,
    int? score,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'exercise_name': exerciseName,
      };

      if (score != null) {
        body['score'] = score;
      } else if (correctReps != null && totalReps != null) {
        body['correct_reps'] = correctReps;
        body['total_reps'] = totalReps;
      }

      final response = await ApiService.postJson(
        '/api/body-training/score',
        body,
        authorized: true,
      );

      // Refresh global weekly progress so the dashboard updates automatically
      getProgress('week').catchError((_) => ProgressData.empty);

      final data = response['data'] as Map<String, dynamic>?;
      return (data?['score'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('⚠️ [ProgressService] Failed to save body training score: $e');
      // Don't rethrow — this is a secondary call, shouldn't break the main flow
      return 0;
    }
  }
}
