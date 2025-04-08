import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'kinetics_model.dart';

class PowerLawModel extends StatelessWidget implements KineticsModel {
  final bool isReversible;
  
  const PowerLawModel({
    super.key,
    required this.isReversible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRateEquation(),
        const SizedBox(height: 24),
        buildParameterFields(),
      ],
    );
  }

  @override
  Widget buildRateEquation() {
    String latex = isReversible
        ? r'r = A e^{\frac{-E}{RT}} \left( [CH_4]^m [CO_2]^n - \frac{[H_2]^p [CO]^q}{K_p} \right)'
        : r'r = A e^{\frac{-E}{RT}} [CH_4]^m [CO_2]^n';

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

  @override
  Widget buildParameterFields() {
    final List<Map<String, String>> fields = isReversible
        ? [
            {'label': 'A', 'hint': 'Pre-exponential factor'},
            {'label': 'E', 'hint': 'Activation energy (J/mol)'},
            {'label': 'm', 'hint': 'CH₄ reaction order'},
            {'label': 'n', 'hint': 'CO₂ reaction order'},
            {'label': 'p', 'hint': 'H₂ reaction order'},
            {'label': 'q', 'hint': 'CO reaction order'},
            {'label': 'Kₚ', 'hint': 'Equilibrium constant'},
          ]
        : [
            {'label': 'A', 'hint': 'Pre-exponential factor'},
            {'label': 'E', 'hint': 'Activation energy (J/mol)'},
            {'label': 'm', 'hint': 'CH₄ reaction order'},
            {'label': 'n', 'hint': 'CO₂ reaction order'},
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
