class Doctor {
  final String id;
  final String name;
  final String specialization;
  final List<String> clinics;
  final String phoneNumber;
  final double rating;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.clinics,
    required this.phoneNumber,
    this.rating = 0.0,
    this.imageUrl = '',
  });

  String get clinicAddress => clinics.isNotEmpty ? clinics.first : 'No clinic address';

  factory Doctor.fromJson(Map<String, dynamic> json) {
    List<String> parsedClinics = [];
    if (json['clinics'] is List) {
      parsedClinics = List<String>.from(json['clinics'].map((c) => c.toString()));
    } else if (json['clinic_address'] != null || json['clinicAddress'] != null) {
      parsedClinics = [(json['clinic_address'] ?? json['clinicAddress']).toString()];
    }

    return Doctor(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown Doctor').toString(),
      specialization: (json['specialization'] ?? 'Specialist').toString(),
      clinics: parsedClinics,
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

// Dummy data for testing
final List<Doctor> dummyDoctors = [
  Doctor(
    id: '1',
    name: 'Dr. Ahmed Mahmoud',
    specialization: 'Pediatrician',
    clinics: ['Maadi St, Cairo'],
    phoneNumber: '01012345678',
    rating: 4.8,
    imageUrl: 'assets/images/doctor1.png',
  ),
  Doctor(
    id: '2',
    name: 'Dr. Sarah Khaled',
    specialization: 'Speech Therapist',
    clinics: ['Nasr City, Cairo'],
    phoneNumber: '01012345679',
    rating: 4.9,
    imageUrl: 'assets/images/doctor2.png',
  ),
];
