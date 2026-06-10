import 'package:flutter/material.dart';
import 'package:step_up/models/appointment_model.dart';
import 'package:step_up/screens/doctor/chat_room_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  final String doctorId;

  const PatientDetailsScreen({
    super.key, 
    required this.appointment,
    required this.doctorId,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.appointment.childName} Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.child_care, size: 40, color: Color(0xFF00796B)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.appointment.childName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text('Patient Record', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      Text('Weight: ${widget.appointment.weight} kg | Height: ${widget.appointment.height} cm', style: const TextStyle(color: Colors.grey)),
                      Text('Parent: ${widget.appointment.parent?.name ?? "N/A"} (${widget.appointment.parent?.phoneNumber ?? ""})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Mock Data showing progress
            const Text('Motor Skills Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildProgressItem('Walking Independently', 0.8),
            _buildProgressItem('Standing on one foot', 0.4),
            _buildProgressItem('Climbing stairs', 0.6),

            const SizedBox(height: 24),
            const Text('Speech Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildProgressItem('Vocabulary (50 words)', 0.9),
            _buildProgressItem('Two-word sentences', 0.5),
            
            const SizedBox(height: 24),
            const Text('Booking Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.appointment.description.isEmpty ? 'No notes provided' : widget.appointment.description,
                style: const TextStyle(color: Colors.black87),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Recent Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Color(0xFF00796B)),
                title: const Text('Physical Therapy - Session 4'),
                subtitle: const Text('2 days ago - Excellent response to standing exercises.'),
                trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
              ),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final parentId = widget.appointment.parent?.id ?? widget.appointment.parent?.phoneNumber ?? 'N/A';
          final parentName = widget.appointment.parent?.name ?? 'Parent';
          
          if (widget.doctorId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Doctor ID still loading. Please wait a moment.')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                parentId: parentId,
                parentName: parentName,
                doctorId: widget.doctorId,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF00796B),
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text('Chat with Parent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

