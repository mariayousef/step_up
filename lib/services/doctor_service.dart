import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
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

  // Parent books an appointment
  static Future<bool> bookAppointment({
    required int doctorId,
    required String childName,
    required double weight,
    required double height,
    required String description,
  }) async {
    try {
      await ApiService.postJson(
        '/api/appointments',
        {
          'doctor_id': doctorId,
          'child_name': childName,
          'weight': weight,
          'height': height,
          'description': description,
        },
        authorized: true,
      );
      return true;
    } catch (e) {
      print("Error booking appointment: $e");
      return false;
    }
  }

  // Parent sees their appointments
  static Future<List<Appointment>> fetchParentAppointments() async {
    try {
      final response = await ApiService.getJson('/api/appointments', authorized: true);
      final list = _extractList(response);
      return list.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching parent appointments: $e");
      return [];
    }
  }

  // Doctor sees their appointments
  static Future<List<Appointment>> fetchDoctorAppointments() async {
    try {
      final response = await ApiService.getJson('/api/doctor/appointments', authorized: true);
      final list = _extractList(response);
      return list.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching doctor appointments: $e");
      return [];
    }
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map) {
      for (final key in const ['doctors', 'appointments', 'data', 'results']) {
        final value = response[key];
        if (value is List) return value;
      }
    }

    return const [];
  }
}
