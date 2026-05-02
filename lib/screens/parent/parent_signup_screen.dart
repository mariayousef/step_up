import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/models/register_request_model.dart';

class ParentSignupScreen extends StatefulWidget {
  const ParentSignupScreen({super.key});

  @override
  State<ParentSignupScreen> createState() => _ParentSignupScreenState();
}

class _ParentSignupScreenState extends State<ParentSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept terms & privacy policy to continue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final parent = ParentModel(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    Navigator.pushNamed(
      context,
      '/child_info',
      arguments: parent,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFDFDFD),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F9FF), Color(0xFF9DF1D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 42,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      "Create Account 🌟",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Join BrightSteps and support your\nchild’s development journey.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration(
                                label: "Full Name",
                                icon: Icons.person_outline,
                              ),
                              validator: (v) =>
                              v == null || v.isEmpty
                                  ? "Please enter your full name"
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration(
                                label: "Email",
                                icon: Icons.email_outlined,
                              ),
                              validator: (v) =>
                              v == null || !v.contains('@')
                                  ? "Please enter a valid email"
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _phoneController,
                              decoration: _inputDecoration(
                                label: "Phone Number",
                                icon: Icons.phone_android_outlined,
                              ),
                              validator: (v) =>
                              v == null || v.length < 7
                                  ? "Please enter a valid phone number"
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: _inputDecoration(
                                label: "Password",
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) =>
                              v == null || v.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: _inputDecoration(
                                label: "Confirm Password",
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) =>
                              v != _passwordController.text
                                  ? "Passwords do not match"
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _acceptTerms = v ?? false),
                                ),
                                const Expanded(
                                  child: Text(
                                    "I agree to Terms & Privacy Policy",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _onSignUp,
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/parent_login'),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
