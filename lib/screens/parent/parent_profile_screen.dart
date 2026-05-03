import 'package:flutter/material.dart';
import 'package:step_up/SettingsScreen.dart';
import 'package:step_up/pin_storage.dart';
import 'package:step_up/child_dashboard_screen.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/services/api_service.dart';
import 'package:step_up/services/auth_service.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  Map<String, dynamic> parentInfo = {'name': 'Loading...'};
  Map<String, dynamic> childInfo = {
    'childName': 'Loading...',
    'age': '...',
    'gender': '...',
    'phoneNumber': '...',
    'caseInformation': 'No information provided.',
  };

  bool _isEditMode = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Pre-initialize all required controllers
    _controllers['name'] = TextEditingController();
    _controllers['phone'] = TextEditingController();
    _controllers['childName'] = TextEditingController();
    _controllers['age'] = TextEditingController();
    _controllers['gender'] = TextEditingController();
    _controllers['phoneNumber'] = TextEditingController();
    _controllers['caseInformation'] = TextEditingController();
    
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userData = await ApiService.getUser();
    print("FINAL_DEBUG_PROFILE: $userData");
    
    if (userData != null) {
      setState(() {
        // Parent Info
        parentInfo['name'] = userData['name'] ?? userData['full_name'] ?? userData['parent_name'] ?? 'User';
        parentInfo['phone'] = userData['phone_number'] ?? userData['phone'] ?? 'Parent Account';
        
        // Child Info
        childInfo['childName'] = userData['child_name'] ?? userData['name'] ?? 'Not set';
        childInfo['age'] = (userData['child_age'] ?? userData['age'])?.toString() ?? 'Not set';
        childInfo['gender'] = userData['child_gender'] ?? userData['gender'] ?? 'Not set';
        childInfo['phoneNumber'] = userData['phone_number'] ?? userData['phone'] ?? 'Not set';
        childInfo['caseInformation'] = userData['case_information'] ?? 'No information provided.';
        
        // Update all controllers
        _controllers['name']?.text = parentInfo['name'];
        _controllers['phone']?.text = parentInfo['phone'];
        _controllers['childName']?.text = childInfo['childName'];
        _controllers['age']?.text = childInfo['age'];
        _controllers['gender']?.text = childInfo['gender'];
        _controllers['phoneNumber']?.text = childInfo['phoneNumber'];
        _controllers['caseInformation']?.text = childInfo['caseInformation'];
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) _saveChanges();
    });
  }

  void _saveChanges() {
    setState(() {
      parentInfo.forEach((key, _) {
        parentInfo[key] = _controllers[key]!.text;
      });
      childInfo.forEach((key, _) {
        childInfo[key] = _controllers[key]!.text;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ================== Child Mode Logic ==================
  Future<void> _enterChildMode() async {
    final hasPin = await PinStorage.hasPin();

    if (!hasPin) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Child Mode PIN'),
          content: const Text(
            'You have not set a PIN yet.\nPlease go to Settings first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final pinController = TextEditingController();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Child Mode PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final enteredPin = pinController.text.trim();
              final isCorrect = await PinStorage.isCorrectPin(enteredPin);

              if (!mounted) return;

              if (isCorrect) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correct PIN!'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 800),
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChildDashboardScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wrong PIN'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildChildInfoSection(),
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/role_selection',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 14),

          // Parent name
          _isEditMode
              ? TextFormField(
            controller: _controllers['name'],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
              : Text(
            parentInfo['name']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),

          const SizedBox(height: 4),
          const Text(
            'Parent Account',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // Enter Child Mode
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enterChildMode,
              icon: const Icon(Icons.child_care),
              label: const Text(
                'Enter Child Mode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildChildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Child Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                ElevatedButton(
                  onPressed: _toggleEditMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isEditMode ? AppColors.primary : Colors.white,
                    foregroundColor:
                    _isEditMode ? Colors.white : AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: Text(_isEditMode ? 'Save' : 'Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Child Name', 'childName', Icons.badge),
            const SizedBox(height: 12),
            _buildInfoRow('Age', 'age', Icons.cake_outlined),
            const SizedBox(height: 12),
            _buildInfoRow('Gender', 'gender', Icons.wc),
            const SizedBox(height: 12),
            _buildInfoRow('Phone', 'phoneNumber', Icons.phone),
            const SizedBox(height: 16),
            _buildMultilineInfoRow(
              'Case Information',
              'caseInformation',
              Icons.health_and_safety_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String key, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              _isEditMode
                  ? TextFormField(
                controller: _controllers[key],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
                  : Text(
                childInfo[key] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultilineInfoRow(
      String label,
      String key,
      IconData icon,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              _isEditMode
                  ? TextFormField(
                controller: _controllers[key],
                maxLines: 3,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
                  : Text(
                childInfo[key] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
