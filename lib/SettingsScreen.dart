import 'package:flutter/material.dart';
import 'pin_storage.dart';
import 'screens/LoginScreen.dart'; // تأكد أن ملف LoginScreen موجود لديك

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ====== Child Mode PIN ======
  void _showChildModePinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Child Mode PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set a 4-digit PIN to secure Child Mode:'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter PIN',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a PIN';
                    if (value.length != 4) return 'PIN must be 4 digits';
                    if (int.tryParse(value) == null) return 'PIN must be numbers only';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm PIN',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm PIN';
                    if (value != pinController.text) return 'PINs do not match';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final pin = pinController.text.trim();
                await PinStorage.savePin(pin);

                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN set successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save PIN'),
            ),
          ],
        );
      },
    );
  }

  // ====== Notifications ======
  void _showNotificationSettingsDialog(BuildContext context) {
    bool progressNotifications = true;
    bool locationAlerts = true;
    bool weeklyReports = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Notification Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Progress Updates'),
                    subtitle: const Text('Daily progress notifications'),
                    value: progressNotifications,
                    onChanged: (value) => setState(() => progressNotifications = value),
                  ),
                  SwitchListTile(
                    title: const Text('Location Alerts'),
                    subtitle: const Text('Safe zone entry/exit alerts'),
                    value: locationAlerts,
                    onChanged: (value) => setState(() => locationAlerts = value),
                  ),
                  SwitchListTile(
                    title: const Text('Weekly Reports'),
                    subtitle: const Text('Weekly progress summary'),
                    value: weeklyReports,
                    onChanged: (value) => setState(() => weeklyReports = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification settings saved!')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ====== About / Help / Logout ======
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & Support'), onTap: () => Navigator.pop(context)),
            const Divider(),
            ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Terms of Service'), onTap: () => Navigator.pop(context)),
            const Divider(),
            ListTile(leading: const Icon(Icons.security_outlined), title: const Text('Privacy Policy'), onTap: () => Navigator.pop(context)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out'),
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
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsCard(title: 'Child Mode Security', subtitle: 'Set PIN for Child Mode access', icon: Icons.child_friendly, onTap: () => _showChildModePinDialog(context)),
            const SizedBox(height: 16),
            _buildSettingsCard(title: 'Notifications', subtitle: 'Manage app notifications', icon: Icons.notifications_active, onTap: () => _showNotificationSettingsDialog(context)),
            const SizedBox(height: 16),
            _buildSettingsCard(title: 'About', subtitle: 'Help, Terms, Privacy Policy', icon: Icons.info_outline, onTap: () => _showAboutDialog(context)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}