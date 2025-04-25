import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/power_law_model.dart';
import '../models/eley_rideal_model.dart';
import '../models/langmuir_hinshelwood_model.dart';
import '../../../../constants/kinetics_constants.dart';

class KineticsTab extends StatefulWidget {
  const KineticsTab({super.key});

  @override
  State<KineticsTab> createState() => _KineticsTabState();
}

class _KineticsTabState extends State<KineticsTab> {
  String selectedKinetics = 'Power-Law';
  final List<String> kineticsOptions = [
    'Power-Law',
    'Eley-Rideal',
    'Langmuir-Hinshelwood',
  ];

  String selectedRateUnit = KineticsConstants.rateUnits[0];
  
  // Reaction selection state
  Map<String, bool> selectedReactions = {
    'SMR': false,
    'DRM': true,  // Default to DRM selected
    'WGS': false,
  };

  // Reversibility state for each reaction
  Map<String, bool> isReversible = {
    'SMR': false,
    'DRM': false,
    'WGS': false,
  };

  // Reaction equations in LaTeX
  final Map<String, String> reactionEquations = {
    'SMR': r'\text{CH}_4 + \text{H}_2\text{O} \rightleftharpoons \text{CO} + 3\text{H}_2',
    'DRM': r'\text{CH}_4 +\text{CO}_2 \rightleftharpoons 2\text{CO} + 2\text{H}_2',
    'WGS': r'\text{CO} +\text{H}_2\text{O} \rightleftharpoons \text{CO}_2 + \text{H}_2',
  };

  // Reaction full names
  final Map<String, String> reactionNames = {
    'SMR': 'Steam Methane Reforming',
    'DRM': 'Dry Methane Reforming',
    'WGS': 'Water-Gas-Shift',
  };

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
            _buildReactionSelectionSection(),
            const SizedBox(height: 24),
            ...selectedReactions.entries
                .where((entry) => entry.value)
                .map((entry) => _buildReactionExpansionTile(entry.key))
                .toList(),
            const SizedBox(height: 24),
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

  Widget _buildReactionSelectionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Reactions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...selectedReactions.keys.map((reaction) => CheckboxListTile(
              title: Text(reactionNames[reaction]!),
              value: selectedReactions[reaction],
              onChanged: (value) {
                setState(() {
                  selectedReactions[reaction] = value!;
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionExpansionTile(String reactionType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(reactionNames[reactionType]!),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
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
                    reactionEquations[reactionType]!,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Checkbox(
                value: isReversible[reactionType],
                onChanged: (value) {
                  setState(() {
                    isReversible[reactionType] = value!;
                  });
                },
              ),
              const Text('Reversible'),
            ],
          ),
          const SizedBox(height: 16),
          _buildKineticsModelForReaction(reactionType),
        ],
      ),
    );
  }

  Widget _buildKineticsModelForReaction(String reactionType) {
    switch (selectedKinetics) {
      case 'Eley-Rideal':
        return EleyRidealModel(
          isReversible: isReversible[reactionType]!,
          reactionType: reactionType,
        );
      case 'Langmuir-Hinshelwood':
        return LangmuirHinshelwoodModel(
          isReversible: isReversible[reactionType]!,
          reactionType: reactionType,
        );
      case 'Power-Law':
      default:
        return PowerLawModel(
          isReversible: isReversible[reactionType]!,
          reactionType: reactionType,
        );
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
