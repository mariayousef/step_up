import 'package:step_up/models/users_data_model.dart';
import 'package:step_up/services/api_service.dart';

class UsersDataService {
  static const String _endpoint = '/api/users-data';

  static Future<UsersDataResponse> fetchUsersData() async {
    try {
      // 1. First priority: The local data saved during login
      final localData = await ApiService.getUser();
      if (localData != null) {
        if (localData.containsKey('parents') || localData.containsKey('children') || localData.containsKey('doctors')) {
          final parsedLocal = UsersDataResponse.fromJson({
            'status': true,
            'message': 'Loaded from local storage',
            'data': localData,
          });
          
          if (parsedLocal.data.parents.isNotEmpty || parsedLocal.data.children.isNotEmpty || parsedLocal.data.doctors.isNotEmpty) {
            return parsedLocal;
          }
        }
      }

      // 2. Second priority: Fetch from backend with required query parameters
      try {
        final token = await ApiService.getToken();
        
        // Robust userId extraction
        dynamic userId = localData != null ? localData['id'] : null;
        if (userId == null && localData != null) {
          if (localData['user'] is Map) userId = localData['user']['id'];
          else if (localData['parent'] is Map) userId = localData['parent']['id'];
          else if (localData['data'] is Map) userId = localData['data']['id'];
        }

        String url = _endpoint;
        if (userId != null) {
          url += '?id=$userId&token=$token';
        } else if (token != null) {
          url += '?token=$token';
        }

        print("UsersDataService: Fetching from $url (Resolved userId: $userId)");
        final response = await ApiService.getJson(url, authorized: true);
        final parsed = UsersDataResponse.fromJson(response);
        
        // Failsafe: If the backend STILL returns the entire database, filter it!
        if (parsed.data.parents.length > 1) {
          dynamic userEmail = localData != null ? localData['email'] : null;
          List<ParentData> matchedParents = [];

          if (userId != null) {
            final targetId = int.tryParse(userId.toString()) ?? 0;
            matchedParents = parsed.data.parents.where((p) => p.id == targetId).toList();
          }

          if (matchedParents.isEmpty && userEmail != null) {
            final emailStr = userEmail.toString().trim().toLowerCase();
            matchedParents = parsed.data.parents.where((p) => p.email.trim().toLowerCase() == emailStr).toList();
          }

          if (matchedParents.isNotEmpty) {
            final targetId = matchedParents.first.id;
            // Found the specific parent, now find their children
            final matchedChildren = parsed.data.children.where((c) => c.parentId == targetId).toList();
            return UsersDataResponse(
              status: true,
              message: 'Filtered local database',
              data: UsersData(
                parents: matchedParents,
                children: matchedChildren,
                doctors: parsed.data.doctors,
              )
            );
          }
        }
        
        return parsed;
      } catch (e) {
        print("API /users-data error: $e");
      }

      return UsersDataResponse(
        status: false, 
        message: 'No data found', 
        data: UsersData(parents: [], children: [], doctors: [])
      );
    } catch (e) {
      throw Exception('Failed to fetch users data: $e');
    }
  }
}
