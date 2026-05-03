import '../models/doctor_model.dart';
import 'api_service.dart';

class DoctorService {
  static Future<List<Doctor>> fetchDoctors() async {
    final response = await ApiService.getJson('/api/doctors', authorized: true);
    final doctorsJson = _extractList(response);

    return doctorsJson
        .whereType<Map>()
        .map((doctor) => Doctor.fromJson(Map<String, dynamic>.from(doctor)))
        .toList();
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map) {
      for (final key in const ['doctors', 'data', 'results']) {
        final value = response[key];
        if (value is List) return value;
      }
    }

    return const [];
  }
}
