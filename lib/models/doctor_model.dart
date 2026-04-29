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
}

// Dummy data for testing
final List<Doctor> dummyDoctors = [
  Doctor(
    id: '1',
    name: 'Dr. Ahmed Mahmoud',
    specialization: 'Pediatrician',
    clinicAddress: 'Maadi St, Cairo',
    rating: 4.8,
    imageUrl: 'assets/images/doctor1.png', // We can use a default icon if not available
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
