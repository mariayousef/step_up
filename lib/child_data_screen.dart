// ChildDataScreen.dart
import 'package:flutter/material.dart';
import 'package:step_up/LoginScreen.dart';
import 'package:step_up/app_colors.dart';
import 'package:step_up/signup_screen.dart';

class ChildDataScreen extends StatefulWidget {
  const ChildDataScreen({super.key});

  @override
  State<ChildDataScreen> createState() => _ChildDataScreenState();
}

class _ChildDataScreenState extends State<ChildDataScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String selectedGender = 'Boy'; // الافتراضي

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Information'),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter Child Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 30),

            // Child Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                labelText: "Child's Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Child Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.cake, color: AppColors.primary),
                labelText: "Child's Age",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Child Gender
            Row(
              children: [
                const Text(
                  "Child's Gender:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                ChoiceChip(
                  label: const Text('Boy'),
                  selected: selectedGender == 'Boy',
                  selectedColor: AppColors.primary.withOpacity(0.2),
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
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedGender = 'Girl';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }, child: Text("Sign Up")
            ),
          ],
        ),
      ),
    );
  }
}