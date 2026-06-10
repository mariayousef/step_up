import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:step_up/screens/doctor/doctor_home_screen.dart';
import 'package:step_up/services/api_service.dart';
import 'package:step_up/services/doctor_auth_service.dart';

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
  final TextEditingController _specializationController =
      TextEditingController();

  final List<TextEditingController> _clinicControllers = [
    TextEditingController(),
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _specializationController.dispose();
    for (var controller in _clinicControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    final clinics = _clinicControllers
        .map((controller) => controller.text.trim())
        .where((clinic) => clinic.isNotEmpty)
        .toList();

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _specializationController.text.trim().isEmpty ||
        clinics.isEmpty) {
      _showMessage('Please complete all doctor details');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DoctorAuthService.registerDoctor(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        specialization: _specializationController.text.trim(),
        clinics: clinics,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login with your credentials.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); 
    } on ApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
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
              const SizedBox(height: 16),
              FadeInLeft(
                delay: const Duration(milliseconds: 750),
                child: _buildTextField(
                  controller: _specializationController,
                  hint: 'Specialization',
                  icon: Icons.medical_information_outlined,
                ),
              ),
              const SizedBox(height: 24),

              FadeInLeft(
                delay: const Duration(milliseconds: 800),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Workplaces',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addClinicField,
                      icon: const Icon(Icons.add, color: Color(0xFF00796B)),
                      label: const Text(
                        'Add Clinic/Hospital',
                        style: TextStyle(
                          color: Color(0xFF00796B),
                          fontWeight: FontWeight.bold,
                        ),
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
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
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
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Account & Log In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    Widget? suffixIcon,
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
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
