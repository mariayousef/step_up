class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String clinicAddress;
  final double rating;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.clinicAddress,
    required this.rating,
    required this.imageUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final clinics = json['clinics'];
    final clinicAddress = clinics is List && clinics.isNotEmpty
        ? clinics.first.toString()
        : (json['clinic_address'] ?? json['clinicAddress'] ?? '').toString();

    return Doctor(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown Doctor').toString(),
      specialization: (json['specialization'] ?? 'Specialist').toString(),
      clinicAddress: clinicAddress.isEmpty
          ? 'No clinic address'
          : clinicAddress,
      rating: _double(json['rating']) ?? 0,
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
    );
  }

  static double? _double(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

// Dummy data for testing
final List<Doctor> dummyDoctors = [
  Doctor(
    id: '1',
    name: 'Dr. Ahmed Mahmoud',
    specialization: 'Pediatrician',
    clinicAddress: 'Maadi St, Cairo',
    rating: 4.8,
    imageUrl:
        'assets/images/doctor1.png', // We can use a default icon if not available
  ),
  Doctor(
    id: '2',
    name: 'Dr. Sarah Khaled',
    specialization: 'Speech Therapist',
    clinicAddress: 'Nasr City, Cairo',
    rating: 4.9,
    imageUrl: 'assets/images/doctor2.png',
  ),
  Doctor(
    id: '3',
    name: 'Dr. Mohamed Ali',
    specialization: 'Pediatric Physiotherapy',
    clinicAddress: 'Mohandeseen, Giza',
    rating: 4.7,
    imageUrl: 'assets/images/doctor3.png',
  ),
  Doctor(
    id: '4',
    name: 'Dr. Fatima Hassan',
    specialization: 'Behavior Modification',
    clinicAddress: 'Heliopolis, Cairo',
    rating: 4.6,
    imageUrl: 'assets/images/doctor4.png',
  ),
];
