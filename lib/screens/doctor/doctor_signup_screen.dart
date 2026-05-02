import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:step_up/screens/doctor/doctor_home_screen.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final List<TextEditingController> _clinicControllers = [TextEditingController()];

  void _addClinicField() {
    setState(() {
      _clinicControllers.add(TextEditingController());
    });
  }

  void _removeClinicField(int index) {
    if (_clinicControllers.length > 1) {
      setState(() {
        _clinicControllers[index].dispose();
        _clinicControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    for (var controller in _clinicControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: const Text(
                  'Doctor Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00796B),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: const Text(
                  'Please fill out the following details to join the platform',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              FadeInLeft(
                delay: const Duration(milliseconds: 400),
                child: _buildTextField(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                delay: const Duration(milliseconds: 500),
                child: _buildTextField(
                  controller: _emailController,
                  hint: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                delay: const Duration(milliseconds: 600),
                child: _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                delay: const Duration(milliseconds: 700),
                child: _buildTextField(
                  controller: _phoneController,
                  hint: 'Mobile Number',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 24),
              
              FadeInLeft(
                delay: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workplaces',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    TextButton.icon(
                      onPressed: _addClinicField,
                      icon: const Icon(Icons.add, color: Color(0xFF00796B)),
                      label: const Text(
                        'Add Clinic/Hospital',
                        style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              ...List.generate(_clinicControllers.length, (index) {
                return FadeInLeft(
                  delay: Duration(milliseconds: 800 + (index * 100)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _clinicControllers[index],
                            hint: 'Clinic / Hospital Address ${index + 1}',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                        if (_clinicControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => _removeClinicField(index),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Create Account & Log In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
