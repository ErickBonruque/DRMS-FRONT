import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'kinetics_models/power_law.dart';
import 'kinetics_models/eley_rideal.dart';
import 'kinetics_models/langmuir_hinshelwood.dart';
import 'kinetics_models/kinetics_constants.dart';

class KineticsPage extends StatefulWidget {
  const KineticsPage({super.key});

  @override
  State<KineticsPage> createState() => _KineticsPageState();
}

class _KineticsPageState extends State<KineticsPage> {
  String selectedKinetics = 'Power-Law';
  final List<String> kineticsOptions = [
    'Power-Law',
    'Eley-Rideal',
    'Langmuir-Hinshelwood',
  ];

  String selectedRateUnit = KineticsConstants.rateUnits[0];
  bool isReversible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedKinetics,
              items: kineticsOptions
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKinetics = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Kinetics'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Math.tex(
                      r'CH_4 + CO_2 \rightleftharpoons 2H_2 + 2CO',
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Checkbox(
                  value: isReversible,
                  onChanged: (value) {
                    setState(() {
                      isReversible = value!;
                    });
                  },
                ),
                const Text('Reversible'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSelectedKineticsModel(),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRateUnitDropdown(),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '*Energy of Activation (E) in J/mol',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedKineticsModel() {
    switch (selectedKinetics) {
      case 'Eley-Rideal':
        return EleyRidealModel(isReversible: isReversible);
      case 'Langmuir-Hinshelwood':
        return LangmuirHinshelwoodModel(isReversible: isReversible);
      case 'Power-Law':
      default:
        return PowerLawModel(isReversible: isReversible);
    }
  }

  Widget _buildRateUnitDropdown() {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: selectedRateUnit,
        items: KineticsConstants.rateUnits
            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedRateUnit = value!;
          });
        },
        decoration: const InputDecoration(),
      ),
    );
  }
}