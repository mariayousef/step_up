class UsersDataResponse {
  final bool status;
  final String message;
  final UsersData data;

  UsersDataResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UsersDataResponse.fromJson(Map<String, dynamic> json) {
    return UsersDataResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UsersData.fromJson(json['data'] ?? {}),
    );
  }
}

class UsersData {
  final List<ParentData> parents;
  final List<ChildData> children;
  final List<DoctorData> doctors;

  UsersData({
    required this.parents,
    required this.children,
    required this.doctors,
  });

  factory UsersData.fromJson(Map<String, dynamic> json) {
    return UsersData(
      parents: (json['parents'] as List?)
              ?.map((e) => ParentData.fromJson(e))
              .toList() ??
          [],
      children: (json['children'] as List?)
              ?.map((e) => ChildData.fromJson(e))
              .toList() ??
          [],
      doctors: (json['doctors'] as List?)
              ?.map((e) => DoctorData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ParentData {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;

  ParentData({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory ParentData.fromJson(Map<String, dynamic> json) {
    return ParentData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}

class ChildData {
  final int id;
  final String name;
  final int age;
  final String gender;
  final int parentId;

  ChildData({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.parentId,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      parentId: json['parent_id'] ?? 0,
    );
  }
}

class DoctorData {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;

  DoctorData({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory DoctorData.fromJson(Map<String, dynamic> json) {
    return DoctorData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}
