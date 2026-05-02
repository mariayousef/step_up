import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final bool isPendingRequest; // True if opened from Notifications (Request)

  const PatientDetailsScreen({
    super.key, 
    required this.patientName,
    this.isPendingRequest = false,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool _isAccepted = false;

  void _acceptRequest() {
    setState(() {
      _isAccepted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request from ${widget.patientName} has been accepted!'),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
    // Pop back to home after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patientName} Details'),
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
                      Text(widget.patientName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text('Age: 4 years, 2 months', style: TextStyle(color: Colors.grey)),
                      const Text('Weight: 16 kg | Height: 102 cm', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            if (widget.isPendingRequest && !_isAccepted) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    const Text('This is a connection request from the parent.', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _acceptRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('Accept Request & Add to Cases'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],

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
            const Text('Recent Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Color(0xFF00796B)),
                title: const Text('Physical Therapy - Session 4'),
                subtitle: const Text('2 days ago - Excellent response to standing exercises.'),
                trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
              ),
            )
          ],
        ),
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
