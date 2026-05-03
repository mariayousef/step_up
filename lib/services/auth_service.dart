import 'api_service.dart';
import '../models/register_request_model.dart';

class AuthService {
  // Parent Registration
  Future<bool> registerParentAndChild(RegisterRequestModel data) async {
    try {
      final response = await ApiService.postJson('/api/auth/register', data.toJson());
      
      // Save input data manually to ensure Profile is populated immediately
      final inputData = {
        'name': data.parent.name,
        'email': data.parent.email,
        'phone_number': data.parent.phoneNumber,
        'child_name': data.child.name,
        'child_age': data.child.age,
        'child_gender': data.child.gender,
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
