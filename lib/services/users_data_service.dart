import 'package:step_up/models/users_data_model.dart';
import 'package:step_up/services/api_service.dart';

class UsersDataService {
  static const String _endpoint = '/api/users-data';

  static Future<UsersDataResponse> fetchUsersData() async {
    try {
      final response = await ApiService.getJson(_endpoint, authorized: true);
      return UsersDataResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch users data: $e');
    }
  }
}
