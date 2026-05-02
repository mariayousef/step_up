import 'package:flutter/material.dart';
import 'package:step_up/screens/doctor/doctor_login_screen.dart';
import 'package:step_up/screens/doctor/doctor_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  // بيانات أساسية
  String _doctorName = 'Dr. Ahmed';
  String _specialty = 'Pediatrician';
  String _clinicInfo = 'Main Hospital, Cairo';
  String _email = 'dr.ahmed@example.com';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // تحميل البيانات لو كانت محفوظة مسبقاً (Local Storage)
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _doctorName = prefs.getString('doc_name') ?? 'Dr. Ahmed';
      _specialty = prefs.getString('doc_spec') ?? 'Pediatrician';
      _clinicInfo = prefs.getString('doc_clinic') ?? 'Main Hospital, Cairo';
      _email = prefs.getString('doc_email') ?? 'dr.ahmed@example.com';
    });
  }

  // حفظ البيانات بعد التعديل
  Future<void> _saveProfileData(String name, String spec, String clinic, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doc_name', name);
    await prefs.setString('doc_spec', spec);
    await prefs.setString('doc_clinic', clinic);
    await prefs.setString('doc_email', email);
    _loadProfileData(); // تحديث الشاشة
  }

  // نافذة التعديل (Edit Profile)
  void _showEditSheet() {
    TextEditingController nameController = TextEditingController(text: _doctorName);
    TextEditingController specController = TextEditingController(text: _specialty);
    TextEditingController clinicController = TextEditingController(text: _clinicInfo);
    TextEditingController emailController = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // ليرتفع بظهور الكيبورد
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Edit Profile Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: specController, decoration: const InputDecoration(labelText: 'Specialty', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: clinicController, decoration: const InputDecoration(labelText: 'Clinic / Hospital', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _saveProfileData(nameController.text, specController.text, clinicController.text, emailController.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorSettingsScreen()),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('English'), leading: const Icon(Icons.check, color: Color(0xFF00796B)), onTap:() => Navigator.pop(context)),
            ListTile(title: const Text('العربية'), onTap:() => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const DoctorLoginScreen()), 
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person, size: 50, color: Color(0xFF00796B)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _showEditSheet,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF00796B), shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(_doctorName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          Center(child: Text('$_specialty | $_clinicInfo', style: const TextStyle(color: Colors.grey))),
          Center(child: Text(_email, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          
          const SizedBox(height: 32),
          
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF00796B)), 
                  title: const Text('Edit Profile Data'), 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showEditSheet,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF00796B)), 
                  title: const Text('Settings'), 
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showSettingsDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF00796B)), 
                  title: const Text('Language'), 
                  trailing: const Text('English', style: TextStyle(color: Colors.grey)),
                  onTap: _showLanguageDialog,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          ElevatedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
