import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ParameterSearchRange extends StatelessWidget {
  final String label;
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool useMathText;

  const ParameterSearchRange({
    Key? key,
    required this.label,
    required this.minController,
    required this.maxController,
    this.useMathText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: useMathText
              ? Math.tex(
                  label,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )
              : Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: minController,
            decoration: const InputDecoration(labelText: 'Min'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: maxController,
            decoration: const InputDecoration(labelText: 'Max'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
