import 'package:flutter/material.dart';
import 'SettingsScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sample data
  Map<String, dynamic> parentInfo = {
    'name': 'Mohamed Ali',
  };

  Map<String, dynamic> childInfo = {
    'childName': 'Ahmed Mohamed',
    'age': '5 years',
    'gender': 'Male',
    'phoneNumber': '+1234567890',
    'caseInformation': 'Autism Spectrum Disorder. The child shows strengths in visual learning and challenges in social communication and interaction. Currently working on improving eye contact and basic communication skills.',
  };

  bool _isEditMode = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all editable fields
    for (var key in parentInfo.keys) {
      _controllers[key] = TextEditingController(text: parentInfo[key]);
    }
    for (var key in childInfo.keys) {
      _controllers[key] = TextEditingController(text: childInfo[key]);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        // Save changes when exiting edit mode
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    setState(() {
      for (var key in parentInfo.keys) {
        parentInfo[key] = _controllers[key]!.text;
      }
      for (var key in childInfo.keys) {
        childInfo[key] = _controllers[key]!.text;
      }
    });
    // In real app, you would save to database/API here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _enterChildMode() {
    // Navigate to child mode interface
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Child Mode'),
        content: const Text('Switch to child-friendly interface?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to child mode screen
              // Navigator.push(context, MaterialPageRoute(builder: (_) => ChildModeScreen()));
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    // Navigate to SettingsScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header with Parent Name and Child Mode Button
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Child Information Section with Edit Button
            _buildChildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // Parent Name (Editable in edit mode)
            _isEditMode
                ? TextFormField(
              controller: _controllers['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            )
                : Text(
              parentInfo['name']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Parent Account',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Child Mode Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _enterChildMode,
                icon: const Icon(Icons.child_care),
                label: const Text('Enter Child Mode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Child Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleEditMode,
                  icon: Icon(_isEditMode ? Icons.save : Icons.edit),
                  label: Text(_isEditMode ? 'Save' : 'Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditMode ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Child Name
            _buildInfoRow('Child Name', 'childName', Icons.badge),
            const SizedBox(height: 16),

            // Age
            _buildInfoRow('Age', 'age', Icons.cake),
            const SizedBox(height: 16),

            // Gender
            _buildInfoRow('Gender', 'gender', Icons.person_outline),
            const SizedBox(height: 16),

            // Phone Number
            _buildInfoRow('Phone Number', 'phoneNumber', Icons.phone),
            const SizedBox(height: 16),

            // Case Information
            _buildCaseInformation(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String key, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              _isEditMode
                  ? TextFormField(
                controller: _controllers[key],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
              )
                  : Text(
                key == 'childName' ? childInfo[key]! :
                key == 'name' ? parentInfo[key]! : childInfo[key]!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaseInformation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.medical_information, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Case Information',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              _isEditMode
                  ? TextFormField(
                controller: _controllers['caseInformation'],
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  hintText: 'Describe the child\'s condition, strengths, challenges, and therapy goals...',
                ),
              )
                  : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  childInfo['caseInformation']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}