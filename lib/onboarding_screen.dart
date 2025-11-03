import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to BrightSteps 💙",
      "subtitle":
      "Parents can monitor their child’s health progress and location safely.",
      "image": "assets/images/onboarding1.png"
    },
    {
      "title": "Track Health & Location 📍",
      "subtitle":
      "Helping children with Down Syndrome grow with love, care and fun activities.",
      "image": "assets/images/onboarding2.png"
    },
    {
      "title": "Play & Learn 🎯",
      "subtitle":
      "Interactive games and speech exercises to help children learn happily!",
      "image": "assets/images/onboarding3.png"
    },
  ];

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top-right)
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 15),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF1FCC79),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      onboardingData[index]['image']!,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      onboardingData[index]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3E5C),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        onboardingData[index]['subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9FA5C0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF1FCC79)
                        : const Color(0xFFD0DBEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Back + Next / Get Started
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  // BACK button
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1FCC79)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        onPressed: () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Color(0xFF1FCC79),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: 10),

                  // NEXT / GET STARTED button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1FCC79),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          _goToLogin();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == onboardingData.length - 1
                            ? "Get Started"
                            : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
