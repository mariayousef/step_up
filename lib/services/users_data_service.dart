import 'package:step_up/models/users_data_model.dart';
import 'package:step_up/services/api_service.dart';

class UsersDataService {
  static const String _endpoint = '/api/users-data';

  static Future<UsersDataResponse> fetchUsersData() async {
    try {
      final token = await ApiService.getToken();
      final user = await ApiService.getUser();
      final userId = user != null ? user['id'] : null;

      String url = _endpoint;
      
      if (userId != null) {
        url += '?id=$userId&token=$token';
      } else if (token != null) {
        url += '?token=$token';
      }

      final response = await ApiService.getJson(url, authorized: true);
      return UsersDataResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch users data: $e');
    }
  }
}
