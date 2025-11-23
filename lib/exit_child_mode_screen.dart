import 'package:flutter/material.dart';
import 'pin_storage.dart';

class ExitChildModeScreen extends StatefulWidget {
  const ExitChildModeScreen({super.key});

  @override
  State<ExitChildModeScreen> createState() => _ExitChildModeScreenState();
}

class _ExitChildModeScreenState extends State<ExitChildModeScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;

  void _onCancel() {
    Navigator.pop(context);
  }

  Future<void> _onSubmit() async {
    final pin = _pinController.text.trim();

    if (pin.length != 4) {
      setState(() => _errorText = 'Please enter a 4-digit PIN');
      return;
    }

    final isCorrect = await PinStorage.isCorrectPin(pin);

    if (!mounted) return;

    if (isCorrect) {
      // إغلاق شاشة الخروج وشاشة الطفل والعودة للبروفايل
      Navigator.of(context).pop(); // Close Exit Screen
      Navigator.of(context).pop(); // Close Child Dashboard
    } else {
      setState(() => _errorText = 'Incorrect PIN. Try again.');
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEBFF), Color(0xFFE3F3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF00C471), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const Text('Do you want to leave\nchild mode?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          decoration: const InputDecoration(border: InputBorder.none, counterText: '', hintText: 'Enter PIN'),
                        ),
                      ),
                      if (_errorText != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_errorText!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: _onCancel, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)), child: const Text('Cancel'))),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton(onPressed: _onSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF00C471)), child: const Text('Submit'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}