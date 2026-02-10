// ChildDataScreen.dart
import 'package:flutter/material.dart';
import 'package:step_up/screens/LoginScreen.dart';
import 'package:step_up/app_colors.dart';

class ChildDataScreen extends StatefulWidget {
  const ChildDataScreen({super.key});

  @override
  State<ChildDataScreen> createState() => _ChildDataScreenState();
}

class _ChildDataScreenState extends State<ChildDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String selectedGender = 'Boy'; // الافتراضي

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    // هنا لاحقًا ممكن تحفظي الداتا في SharedPreferences / Backend لو حبيتي

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // خلفية جradient بدل اللون الثابت
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F9FF),
              Color(0xFF9DF1D3),
            ],
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // عنوان فوق
                    const Text(
                      'Child Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'We’ll use this to personalize\nhealth & activity recommendations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card الأبيض
                    Container(
                      width: double.infinity,
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
                            // Icon
                            const Icon(
                              Icons.child_care,
                              size: 60,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Enter Child Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Child Name
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Child's Name",
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                                labelStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.outline,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFDFDFD),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your child's name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Child Age
                            TextFormField(
                              controller: ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Child's Age",
                                prefixIcon: const Icon(
                                  Icons.cake,
                                  color: AppColors.primary,
                                ),
                                labelStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.outline,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFDFDFD),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter age";
                                }
                                final age = int.tryParse(value);
                                if (age == null || age <= 0) {
                                  return "Please enter a valid age";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Child Gender
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Child's Gender",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Boy'),
                                  selected: selectedGender == 'Boy',
                                  selectedColor:
                                  AppColors.primary.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: selectedGender == 'Boy'
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedGender = 'Boy';
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                ChoiceChip(
                                  label: const Text('Girl'),
                                  selected: selectedGender == 'Girl',
                                  selectedColor:
                                  AppColors.primary.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: selectedGender == 'Girl'
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedGender = 'Girl';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _onContinue,
                        child: const Text(
                          "Save & Continue",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "You can edit child details anytime from Profile.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
