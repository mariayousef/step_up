import 'package:flutter/material.dart';

class MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MiniStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🩺 Icon Circle with soft shadow
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),

        const SizedBox(height: 12),

        // 🔢 Value
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E5C),
          ),
        ),

        const SizedBox(height: 5),

        // 🏷 Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9FA5C0),
          ),
        ),
      ],
    );
  }
}
