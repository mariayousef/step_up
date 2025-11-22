import 'package:flutter/material.dart';
import 'LoginScreen.dart'; // Make sure this import is added

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChildModePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Child Mode PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a 4-digit PIN to secure Child Mode:'),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN set successfully!')),
              );
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool progressNotifications = true;
          bool locationAlerts = true;
          bool weeklyReports = false;

          return AlertDialog(
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Progress Updates'),
                  subtitle: const Text('Daily progress notifications'),
                  value: progressNotifications,
                  onChanged: (value) {
                    setState(() {
                      progressNotifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Location Alerts'),
                  subtitle: const Text('Safe zone entry/exit alerts'),
                  value: locationAlerts,
                  onChanged: (value) {
                    setState(() {
                      locationAlerts = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Weekly Reports'),
                  subtitle: const Text('Weekly progress summary'),
                  value: weeklyReports,
                  onChanged: (value) {
                    setState(() {
                      weeklyReports = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings saved!')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                _showHelpSupportDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms of Service'),
              onTap: () {
                Navigator.pop(context);
                _showTermsDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                _showPrivacyDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Need assistance? We\'re here to help!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildContactInfo('Email', 'support@autismapp.com', Icons.email),
              _buildContactInfo('Phone', '+1 (555) 123-4567', Icons.phone),
              _buildContactInfo('Website', 'www.autismapp.com', Icons.language),
              const SizedBox(height: 16),
              const Text(
                'Office Hours: Mon-Fri, 9AM-5PM',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Last updated: December 2024',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                'By using Autism Companion App, you agree to the following terms:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Use the app for its intended purpose only'),
              Text('• Maintain the confidentiality of your account'),
              Text('• Not misuse any personal data'),
              Text('• Follow all applicable laws and regulations'),
              SizedBox(height: 12),
              Text(
                'We reserve the right to modify these terms at any time.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Your privacy is important to us.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Data We Collect:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Child progress and development data'),
              Text('• Location data for safe zones'),
              Text('• App usage statistics'),
              SizedBox(height: 12),
              Text(
                'How We Use Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Provide personalized therapy recommendations'),
              Text('• Track progress and generate reports'),
              Text('• Improve app features and user experience'),
              SizedBox(height: 12),
              Text(
                'We never sell your personal data to third parties.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Just close dialog, no logout
            child: const Text('Cancel'), // Fixed typo
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _performLogout(context); // Navigate to login screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // Show logout confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to login screen immediately without delay
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Remove all previous routes
    );
  }


  Widget _buildContactInfo(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Child Mode PIN
            _buildSettingsCard(
              title: 'Child Mode Security',
              subtitle: 'Set PIN for Child Mode access',
              icon: Icons.child_friendly,
              onTap: () => _showChildModePinDialog(context),
            ),
            const SizedBox(height: 16),

            // Notifications
            _buildSettingsCard(
              title: 'Notifications',
              subtitle: 'Manage app notifications',
              icon: Icons.notifications_active,
              onTap: () => _showNotificationSettingsDialog(context),
            ),
            const SizedBox(height: 16),

            // About
            _buildSettingsCard(
              title: 'About',
              subtitle: 'Help, Terms, Privacy Policy',
              icon: Icons.info_outline,
              onTap: () => _showAboutDialog(context),
            ),
            const SizedBox(height: 32),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}