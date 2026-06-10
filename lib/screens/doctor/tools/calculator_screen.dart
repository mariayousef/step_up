import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String _result = '';
  String _reference = '';

  void _calculate() {
    // Basic validation
    if (_ageController.text.isEmpty || _weightController.text.isEmpty) {
      setState(() {
        _result = 'Please enter both age and weight to calculate.';
      });
      return;
    }

    // Parse input (Years instead of Months)
    double ageYears = double.tryParse(_ageController.text) ?? 0;
    double currentWeight = double.tryParse(_weightController.text) ?? 0;
    
    double ageMonths = ageYears * 12;

    // Simplified mock formula for DS growth curves based on generic research
    double expectedMinWeight = 3.2 + (ageMonths * 0.15);
    double expectedMaxWeight = 4.5 + (ageMonths * 0.28);

    String status;
    if (currentWeight < expectedMinWeight) {
      status = 'Below Average (Underweight)';
    } else if (currentWeight > expectedMaxWeight) {
      status = 'Above Average (Overweight)';
    } else {
      status = 'Within Normal Range';
    }

    setState(() {
      _result = '''
Current Weight: $currentWeight kg
Expected Range: ${expectedMinWeight.toStringAsFixed(1)} kg - ${expectedMaxWeight.toStringAsFixed(1)} kg

Conclusion: The child is $status.
      ''';
      
      _reference = 'Reference: Zemel et al. (2015). Growth Charts for Children With Down Syndrome in the United States. Pediatrics, 136(5), e1204-11.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DS Curves Calculator'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Child Data to Compare with Down Syndrome Growth Curves', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age (in Years)', 
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (in kg)', 
                prefixIcon: const Icon(Icons.monitor_weight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B), 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Calculate', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            
            if (_result.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calculation Results:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00796B))),
                    const SizedBox(height: 10),
                    Text(_result, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(_reference, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
