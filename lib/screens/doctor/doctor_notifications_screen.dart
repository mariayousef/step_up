import 'package:flutter/material.dart';
import 'package:step_up/screens/doctor/patient_details_screen.dart';

class DoctorNotificationsScreen extends StatelessWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotifItem(
            context,
            'New Connection Request', 
            'Parent Omar has requested to connect for child "Ali". Tap to review.', 
            '10 mins ago', 
            Icons.person_add,
            isRequest: true,
            childName: 'Ali',
          ),
          _buildNotifItem(
            context,
            'System Update', 
            'Your profile was verified successfully.', 
            '2 hours ago', 
            Icons.verified,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifItem(BuildContext context, String title, String subtitle, String time, IconData icon, {bool isRequest = false, String? childName}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFE0F2F1), child: Icon(icon, color: const Color(0xFF00796B))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isRequest && childName != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailsScreen(
                  patientName: childName,
                  isPendingRequest: true, // Passes the flag to show the Accept button!
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
