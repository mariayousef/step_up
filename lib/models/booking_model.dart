import 'doctor_model.dart';

enum BookingStatus { pending, accepted, rejected }

class Booking {
  final String id;
  final Doctor doctor;
  final String childName;
  final BookingStatus status;
  final DateTime date;

  Booking({
    required this.id,
    required this.doctor,
    required this.childName,
    required this.status,
    required this.date,
  });
}

// Dummy data for testing
final List<Booking> dummyBookings = [
  Booking(
    id: 'b1',
    doctor: dummyDoctors[0], // Dr. Ahmed Mahmoud
    childName: 'Ali',
    status: BookingStatus.accepted,
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Booking(
    id: 'b2',
    doctor: dummyDoctors[1], // Dr. Sarah Khaled
    childName: 'Ali',
    status: BookingStatus.pending,
    date: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];
