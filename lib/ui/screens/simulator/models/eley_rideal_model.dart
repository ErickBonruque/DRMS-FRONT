import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'kinetics_model.dart';
import '../../../../constants/kinetics_constants.dart';

class EleyRidealModel extends StatelessWidget implements KineticsModel {
  final bool isReversible;
  final String reactionType;

  const EleyRidealModel({
    super.key, 
    required this.isReversible,
    required this.reactionType,
  });

  @override
  Widget buildRateEquation() {
    String equation;
    switch (reactionType) {
      case 'SMR':
        if (isReversible) {
          equation = r'r_{SMR} = \frac{k_{SMR} \cdot \left(P_{CH_4} \cdot P_{H_2O} - \frac{P_{CO} \cdot P_{H_2}^3}{K_{eq}} \right)}{\left(1 + K_{CH_4, SMR} \cdot P_{CH_4} + K_{H_2O, SMR} \cdot P_{H_2O}\right)}';
        } else {
          equation = r'r_{SMR} = \frac{k_{SMR} \cdot P_{CH_4} \cdot P_{H_2O}}{\left(1 + K_{CH_4, SMR} \cdot P_{CH_4} + K_{H_2O, SMR} \cdot P_{H_2O}\right)}';
        }
        break;
      case 'WGS':
        if (isReversible) {
          equation = r'r_{WGS} = \frac{k_{WGS} \cdot \left(P_{CO} \cdot P_{H_2O} - \frac{P_{CO_2} \cdot P_{H_2}}{K_{eq}} \right)}{\left(1 + K_{CO, WGS} \cdot P_{CO} + K_{H_2O, WGS} \cdot P_{H_2O}\right)}';
        } else {
          equation = r'r_{WGS} = \frac{k_{WGS} \cdot P_{CO} \cdot P_{H_2O}}{\left(1 + K_{CO, WGS} \cdot P_{CO} + K_{H_2O, WGS} \cdot P_{H_2O}\right)}';
        }
        break;
      case 'DRM':
      default:
        if (isReversible) {
          equation = r'r_{DRM} = \frac{k_{DRM} \cdot \left(P_{CH_4} \cdot P_{CO_2} - \frac{P_{CO}^2 \cdot P_{H_2}^2}{K_{eq}} \right)}{\left(1 + K_{CH_4, DRM} \cdot P_{CH_4} + K_{CO_2, DRM} \cdot P_{CO_2}\right)}';
        } else {
          equation = r'r_{DRM} = \frac{k_{DRM} \cdot P_{CH_4} \cdot P_{CO_2}}{\left(1 + K_{CH_4, DRM} \cdot P_{CH_4} + K_{CO_2, DRM} \cdot P_{CO_2}\right)}';
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
    // Define constantes de adsorção específicas para cada reação
    List<String> adsorptionConstants = [];
    switch (reactionType) {
      case 'SMR':
        adsorptionConstants = ['K_{CH_4, SMR}', 'K_{H_2O, SMR}'];
        break;
      case 'WGS':
        adsorptionConstants = ['K_{CO, WGS}', 'K_{H_2O, WGS}'];
        break;
      case 'DRM':
      default:
        adsorptionConstants = ['K_{CH_4, DRM}', 'K_{CO_2, DRM}'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Eley-Rideal Parameters for $reactionType:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
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
                decoration: InputDecoration(
                  labelText: adsorptionConstants[0],
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: adsorptionConstants[1],
                  border: const OutlineInputBorder(),
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
