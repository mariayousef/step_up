import 'api_service.dart';

class DoctorAuthService {
  static Future<void> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String specialization,
    required List<String> clinics,
  }) async {
    final response = await ApiService.postJson('/api/doctor/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'specialization': specialization,
      'clinics': clinics,
      'user_type': 'doctor',
    });

    // Save input data manually for Profile
    final inputData = {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'specialization': specialization,
      'clinics': clinics,
    };
    await ApiService.saveUser(inputData);

    await _saveTokenIfPresent(response);
  }

  static Future<void> loginDoctor({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.postJson('/api/doctor/login', {
      'email': email,
      'password': password,
    });

    await _saveTokenIfPresent(response);
  }

  static Future<String?> _saveTokenIfPresent(dynamic response) async {
    final token = ApiService.extractToken(response);
    if (token != null) {
      await ApiService.saveToken(token);
    }

    // Deeper search for doctor data
    if (response is Map) {
      final userData = response['user'] ?? response['data'] ?? response['doctor'];
      if (userData is Map) {
        print("DOCTOR_AUTH: Saving user data from response: $userData");
        await ApiService.saveUser(Map<String, dynamic>.from(userData));
        await ApiService.saveUserType('doctor');
      }
    }
    return token;
  }
}
