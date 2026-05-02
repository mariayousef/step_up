import 'package:flutter/material.dart';

class DoctorSettingsScreen extends StatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  State<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends State<DoctorSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('App Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for messages and requests'),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF00796B),
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app visual theme'),
            value: _darkModeEnabled,
            activeColor: const Color(0xFF00796B),
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text('Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Delete Account'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
