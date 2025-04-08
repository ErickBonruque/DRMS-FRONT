import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'kinetics_model.dart';

class LangmuirHinshelwoodModel extends StatefulWidget {
  final bool isReversible;
  
  const LangmuirHinshelwoodModel({
    super.key,
    this.isReversible = false,
  });

  @override
  State<LangmuirHinshelwoodModel> createState() => _LangmuirHinshelwoodModelState();
}

class _LangmuirHinshelwoodModelState extends State<LangmuirHinshelwoodModel> implements KineticsModel {
  // Formula type selection - simple or complex
  bool _useComplexFormula = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormulaSelector(),
        const SizedBox(height: 16),
        buildRateEquation(),
        const SizedBox(height: 24),
        buildParameterFields(),
      ],
    );
  }

  Widget _buildFormulaSelector() {
    return Row(
      children: [
        const Text(
          'Equation type:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        ChoiceChip(
          label: const Text('Simple'),
          selected: !_useComplexFormula,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _useComplexFormula = false;
              });
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Complex'),
          selected: _useComplexFormula,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _useComplexFormula = true;
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget buildRateEquation() {
    // Select the appropriate equation based on isReversible and formula complexity
    String latex;
    
    if (widget.isReversible) {
      if (_useComplexFormula) {
        latex = r'r = \frac{A e^{\frac{-E}{RT}} \left( K_{CH_4} K_{CO_2} [CH_4][CO_2] - \frac{[H_2]^2[CO]^2 K_{H_2}^2 K_{CO}^2}{K_p} \right)}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2] + K_{H_2}[H_2] + K_{CO}[CO])^4}';
      } else {
        latex = r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} \left( [CH_4][CO_2] - \frac{[H_2]^2[CO]^2}{K_p} \right)}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}';
      }
    } else {
      if (_useComplexFormula) {
        latex = r'r = \frac{A e^{\frac{-E}{RT}} (K_{CH_4} K_{CO_2} [CH_4][CO_2])}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2] + K_{H_2}[H_2] + K_{CO}[CO])^4}';
      } else {
        latex = r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} [CH_4][CO_2]}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}';
      }
    }

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
    // Define fields based on the formula selected
    List<Map<String, String>> fields = [
      {'label': 'A', 'hint': 'Pre-exponential factor'},
      {'label': 'E', 'hint': 'Activation energy (J/mol)'},
      {'label': 'K₍CH₄₎', 'hint': 'CH₄ adsorption constant'},
      {'label': 'K₍CO₂₎', 'hint': 'CO₂ adsorption constant'},
    ];
    
    // Add additional fields for complex formula
    if (_useComplexFormula) {
      fields.addAll([
        {'label': 'K₍H₂₎', 'hint': 'H₂ adsorption constant'},
        {'label': 'K₍CO₎', 'hint': 'CO adsorption constant'},
      ]);
    }
    
    // Add equilibrium constant for reversible reactions
    if (widget.isReversible) {
      fields.add({'label': 'Kₚ', 'hint': 'Equilibrium constant'});
    }

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
