import 'doctor_model.dart';

class Appointment {
  final String? id;
  final String childName;
  final double weight;
  final double height;
  final String description;
  final Doctor? doctor;
  final ParentInfo? parent;

  Appointment({
    this.id,
    required this.childName,
    required this.weight,
    required this.height,
    required this.description,
    this.doctor,
    this.parent,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Handle Doctor object in response
    Doctor? parsedDoctor;
    if (json['doctor'] != null) {
      parsedDoctor = Doctor.fromJson(Map<String, dynamic>.from(json['doctor']));
    } else if (json['doctor_id'] != null) {
      // Fallback if only doctor_id is present
      parsedDoctor = Doctor(
        id: json['doctor_id'].toString(),
        name: 'Doctor',
        specialization: '',
        clinics: [],
        phoneNumber: '',
      );
    }

    // Handle Parent object in response
    ParentInfo? parsedParent;
    if (json['parent'] != null) {
      parsedParent = ParentInfo.fromJson(Map<String, dynamic>.from(json['parent']));
    } else if (json['parent_id'] != null) {
      // Fallback if only parent_id is present
      parsedParent = ParentInfo(
        id: json['parent_id'].toString(),
        name: 'Parent',
        phoneNumber: '',
      );
    }

    return Appointment(
      id: json['id']?.toString(),
      childName: json['child_name']?.toString() ?? json['childName']?.toString() ?? '',
      weight: _toDouble(json['weight']),
      height: _toDouble(json['height']),
      description: json['description']?.toString() ?? '',
      doctor: parsedDoctor,
      parent: parsedParent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctor?.id,
      'child_name': childName,
      'weight': weight,
      'height': height,
      'description': description,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ParentInfo {
  final String? id;
  final String name;
  final String phoneNumber;

  ParentInfo({this.id, required this.name, required this.phoneNumber});

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'] ?? '').toString(),
    );
  }
}
