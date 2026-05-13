import 'api_service.dart';
import '../models/register_request_model.dart';

class AuthService {
  // Parent Registration
  Future<bool> registerParent({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await ApiService.postJson('/api/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
      });
      
      // Save input data for profile
      final inputData = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
      };
      await ApiService.saveUser(inputData);

      await _saveTokenIfPresent(response);
      return true;
    } catch (e) {
      print("AuthService Error: $e");
      return false;
    }
  }

  // Parent Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.postJson('/api/auth/login', {
        'email': email,
        'password': password,
      });
      
      // Even if response is sparse, save the email as a fallback ID
      await ApiService.saveUser({'email': email});
      
      await _saveTokenIfPresent(response);
      return true;
    } catch (e) {
      print("AuthService Login Error: $e");
      return false;
    }
  }

  Future<void> _saveTokenIfPresent(dynamic response) async {
    final token = ApiService.extractToken(response);
    if (token != null) {
      await ApiService.saveToken(token);
    }
    
    // Deeper search for user data
    if (response is Map) {
      final userData = response['user'] ?? response['data'] ?? response['parent'] ?? response['doctor'];
      if (userData is Map) {
        print("AUTH_SERVICE: Saving user data from response: $userData");
        await ApiService.saveUser(Map<String, dynamic>.from(userData));
        
        // Save user type if present
        final type = userData['user_type'] ?? 'parent';
        await ApiService.saveUserType(type);
      }
    }
  }

  Future<void> logout() async {
    await ApiService.clearAll();
  }
}
