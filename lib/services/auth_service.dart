import 'api_service.dart';
import '../models/register_request_model.dart';

class AuthService {
  // Parent Registration
  Future<bool> registerParent({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? childName,
    int? childAge,
    String? childGender,
  }) async {
    try {
      final parentModel = ParentModel(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      final childModel = ChildModel(
        name: childName ?? 'Unknown',
        age: childAge ?? 0,
        gender: childGender ?? 'male',
      );

      final requestModel = RegisterRequestModel(parent: parentModel, child: childModel);

      final response = await ApiService.postJson(
        '/api/auth/register',
        requestModel.toJson(),
      );
      
      // Save input data for profile
      final inputData = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'child_name': childName,
        'child_age': childAge,
        'child_gender': childGender,
      };
      await ApiService.saveUser(inputData);

      await _saveTokenIfPresent(response);
      return true;
    } on ApiException catch (e) {
      print("AuthService ApiException: ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error: $e");
      throw Exception(e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Clear old data before login to ensure we don't use old tokens
      await ApiService.clearAll();

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
