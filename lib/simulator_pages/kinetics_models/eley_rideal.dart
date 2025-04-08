import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class EleyRidealModel extends StatelessWidget {
  final bool isReversible;
  
  const EleyRidealModel({
    super.key, 
    this.isReversible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRateEquation(),
        const SizedBox(height: 24),
        _buildParameterFields(),
      ],
    );
  }

  Widget _buildRateEquation() {
    final String latex = isReversible
        ? r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} \left( [CH_4][CO_2] - \frac{[H_2]^2[CO]^2}{K_p} \right)}{1 + K_{CH_4}[CH_4]}'
        : r'r = \frac{A e^{\frac{-E}{RT}} \cdot [CH_4] \cdot [CO_2]}{1 + K_{CH_4} \cdot [CH_4]}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Math.tex(
          latex,
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          mathStyle: MathStyle.display,
        ),
      ),
    );
  }

  Widget _buildParameterFields() {
    final List<Map<String, String>> fields = isReversible
        ? [
            {'label': 'A', 'hint': 'Pre-exponential factor'},
            {'label': 'E', 'hint': 'Activation energy (J/mol)'},
            {'label': 'K₍CH₄₎', 'hint': 'Adsorption constant for CH₄'},
            {'label': 'Kₚ', 'hint': 'Equilibrium constant'},
          ]
        : [
            {'label': 'A', 'hint': 'Pre-exponential factor'},
            {'label': 'E', 'hint': 'Activation energy (J/mol)'},
            {'label': 'K₍CH₄₎', 'hint': 'Adsorption constant for CH₄'},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kinetic Parameters:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: fields
              .map(
                (field) => SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: field['label'],
                      hintText: field['hint'],
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
