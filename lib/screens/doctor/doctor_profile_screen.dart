import 'package:flutter/material.dart';
import 'package:step_up/screens/doctor/doctor_login_screen.dart';
import 'package:step_up/screens/doctor/doctor_settings_screen.dart';
import 'package:step_up/services/api_service.dart';

import 'package:step_up/app_colors.dart';

import 'package:step_up/services/users_data_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  // بيانات أساسية
  String _doctorName = '';
  String _specialty = '';
  String _clinicInfo = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // تحميل البيانات من الباك اند
  Future<void> _loadProfileData() async {
    try {
      final response = await UsersDataService.fetchUsersData();
      final doctors = response.data.doctors;
      
      if (mounted && doctors.isNotEmpty) {
        final doctor = doctors.first;
        setState(() {
          _doctorName = doctor.name.isNotEmpty ? doctor.name : '';
          _email = doctor.email.isNotEmpty ? doctor.email : '';
          _phone = doctor.phoneNumber;
          _specialty = 'Specialist'; // Not currently in API response
          _clinicInfo = 'Step Up Clinic'; // Not currently in API response
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

  // حفظ البيانات بعد التعديل (Dummy for now or can call API)
  Future<void> _saveProfileData(String name, String spec, String clinic, String email) async {
    // This can be updated to call a patch/put API if available
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
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
            ListTile(title: const Text('English'), leading: const Icon(Icons.check, color: AppColors.primary), onTap:() => Navigator.pop(context)),
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
            onPressed: () async {
              await ApiService.clearAll();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/role_selection', 
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
          Stack(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 45),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _showEditSheet,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _doctorName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_specialty | $_clinicInfo',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primary), 
              title: const Text('Edit Profile Data', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)), 
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: _showEditSheet,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary), 
              title: const Text('Settings', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)), 
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _showSettingsDialog(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language_outlined, color: AppColors.primary), 
              title: const Text('Language', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)), 
              trailing: const Text('English', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              onTap: _showLanguageDialog,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent), 
              title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)), 
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
