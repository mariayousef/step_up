import 'package:flutter/material.dart';
import 'package:step_up/app_colors.dart';

class ChildDataScreen extends StatefulWidget {
  const ChildDataScreen({super.key});

  @override
  State<ChildDataScreen> createState() => _ChildDataScreenState();
}

class _ChildDataScreenState extends State<ChildDataScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final parentPhoneController = TextEditingController();

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
                labelText: 'Child Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.cake, color: AppColors.primary),
                labelText: 'Age',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parent Phone
            TextField(
              controller: parentPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                labelText: 'Parent Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
