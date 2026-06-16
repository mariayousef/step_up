class RegisterRequestModel {
  final ParentModel parent;
  final ChildModel child;

  RegisterRequestModel({
    required this.parent,
    required this.child,
  });

  Map<String, dynamic> toJson() {
    return {
      "parent": parent.toJson(),
      "child": child.toJson(),
    };
  }
}

/* ================== Parent ================== */

class ParentModel {
  final String name;
  final String phoneNumber;
  final String email;
  final String password;

  ParentModel({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone_number": phoneNumber,
      "email": email,
      "password": password,
      "password_confirmation": password, // Required by Laravel
      "user_type": "parent",
    };
  }
}

/* ================== Child ================== */

class ChildModel {
  final String name;
  final int age;
  final String gender;

  ChildModel({
    required this.name,
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "gender": gender,
      "user_type": "child",
    };
  }
}
