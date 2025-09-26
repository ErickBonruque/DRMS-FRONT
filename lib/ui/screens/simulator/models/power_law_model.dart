import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'kinetics_model.dart';
import '../../../../constants/kinetics_constants.dart';

class PowerLawModel extends StatelessWidget implements KineticsModel {
  final bool isReversible;
  final String reactionType;
  final Map<String, TextEditingController>? controllers;

  const PowerLawModel({
    super.key,
    required this.isReversible,
    required this.reactionType,
    this.controllers,
  });

  @override
  Widget buildRateEquation() {
    String equation;
    switch (reactionType) {
      case 'SMR':
        if (isReversible) {
          equation = r'r_{SMR} = k_{SMR} \cdot \left(P_{CH_4}^{\alpha} \cdot P_{H_2O}^{\beta} - \frac{P_{CO} \cdot P_{H_2}^3}{K_{eq}} \right)';
        } else {
          equation = r'r_{SMR} = k_{SMR} \cdot P_{CH_4}^{\alpha} \cdot P_{H_2O}^{\beta}';
        }
        break;
      case 'WGS':
        if (isReversible) {
          equation = r'r_{WGS} = k_{WGS} \cdot \left(P_{CO}^{\alpha} \cdot P_{H_2O}^{\beta} - \frac{P_{CO_2} \cdot P_{H_2}}{K_{eq}} \right)';
        } else {
          equation = r'r_{WGS} = k_{WGS} \cdot P_{CO}^{\alpha} \cdot P_{H_2O}^{\beta}';
        }
        break;
      case 'DRM':
      default:
        if (isReversible) {
          equation = r'r_{DRM} = k_{DRM} \cdot \left(P_{CH_4}^{\alpha} \cdot P_{CO_2}^{\beta} - \frac{P_{CO}^2 \cdot P_{H_2}^2}{K_{eq}} \right)';
        } else {
          equation = r'r_{DRM} = k_{DRM} \cdot P_{CH_4}^{\alpha} \cdot P_{CO_2}^{\beta}';
        }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: KineticsConstants.equationBoxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Math.tex(
            equation,
            textStyle: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Math.tex(
            r'k_{' + reactionType + r'} = A_{' + reactionType + r'} \cdot \exp \left( \frac{-E_{' + reactionType + r'}}{R \cdot T} \right)',
            textStyle: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildParameterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Power-Law Parameters for $reactionType:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers?['A_$reactionType'],
                decoration: InputDecoration(
                  labelText: 'A_$reactionType',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers?['E_$reactionType'],
                decoration: InputDecoration(
                  labelText: 'E_$reactionType',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers?['alpha_$reactionType'],
                decoration: const InputDecoration(
                  labelText: 'α',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers?['beta_$reactionType'],
                decoration: const InputDecoration(
                  labelText: 'β',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        if (isReversible) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers?['K_eq_$reactionType'],
                  decoration: const InputDecoration(
                    labelText: 'K_eq',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRateEquation(),
        buildParameterFields(),
      ],
    );
  }
}
