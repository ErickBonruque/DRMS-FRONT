import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'kinetics_model.dart';
import '../../../../constants/kinetics_constants.dart';

class LangmuirHinshelwoodModel extends StatelessWidget implements KineticsModel {
  final bool isReversible;
  final String reactionType;

  const LangmuirHinshelwoodModel({
    super.key,
    required this.isReversible,
    required this.reactionType,
  });

  @override
  Widget buildRateEquation() {
    String equation;
    String denominator;
    
    switch (reactionType) {
      case 'SMR':
        denominator = r'\left(1 + K_{CH_4, SMR} \cdot P_{CH_4} + K_{H_2O, SMR} \cdot P_{H_2O} + K_{CO, SMR} \cdot P_{CO} + K_{H_2, SMR} \cdot P_{H_2}\right)^2';
        if (isReversible) {
          equation = r'r_{SMR} = \frac{k_{SMR} \cdot \left(K_{CH_4, SMR} \cdot P_{CH_4} \cdot K_{H_2O, SMR} \cdot P_{H_2O} - \frac{K_{CO, SMR} \cdot P_{CO} \cdot (K_{H_2, SMR} \cdot P_{H_2})^3}{K_{eq}} \right)}{' + denominator + '}';
        } else {
          equation = r'r_{SMR} = \frac{k_{SMR} \cdot K_{CH_4, SMR} \cdot P_{CH_4} \cdot K_{H_2O, SMR} \cdot P_{H_2O}}{' + denominator + '}';
        }
        break;
      case 'WGS':
        denominator = r'\left(1 + K_{CO, WGS} \cdot P_{CO} + K_{H_2O, WGS} \cdot P_{H_2O} + K_{CO_2, WGS} \cdot P_{CO_2} + K_{H_2, WGS} \cdot P_{H_2}\right)^2';
        if (isReversible) {
          equation = r'r_{WGS} = \frac{k_{WGS} \cdot \left(K_{CO, WGS} \cdot P_{CO} \cdot K_{H_2O, WGS} \cdot P_{H_2O} - \frac{K_{CO_2, WGS} \cdot P_{CO_2} \cdot K_{H_2, WGS} \cdot P_{H_2}}{K_{eq}} \right)}{' + denominator + '}';
        } else {
          equation = r'r_{WGS} = \frac{k_{WGS} \cdot K_{CO, WGS} \cdot P_{CO} \cdot K_{H_2O, WGS} \cdot P_{H_2O}}{' + denominator + '}';
        }
        break;
      case 'DRM':
      default:
        denominator = r'\left(1 + K_{CH_4, DRM} \cdot P_{CH_4} + K_{CO_2, DRM} \cdot P_{CO_2} + K_{CO, DRM} \cdot P_{CO} + K_{H_2, DRM} \cdot P_{H_2}\right)^2';
        if (isReversible) {
          equation = r'r_{DRM} = \frac{k_{DRM} \cdot \left(K_{CH_4, DRM} \cdot P_{CH_4} \cdot K_{CO_2, DRM} \cdot P_{CO_2} - \frac{(K_{CO, DRM} \cdot P_{CO})^2 \cdot (K_{H_2, DRM} \cdot P_{H_2})^2}{K_{eq}} \right)}{' + denominator + '}';
        } else {
          equation = r'r_{DRM} = \frac{k_{DRM} \cdot K_{CH_4, DRM} \cdot P_{CH_4} \cdot K_{CO_2, DRM} \cdot P_{CO_2}}{' + denominator + '}';
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
            textStyle: const TextStyle(fontSize: 16),
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
    // Define constantes para os parâmetros de adsorção
    // e os produtos para cada tipo de reação
    List<String> reactants = [];
    List<String> products = [];
    
    switch (reactionType) {
      case 'SMR':
        reactants = ['CH_4', 'H_2O'];
        products = ['CO', 'H_2'];
        break;
      case 'WGS':
        reactants = ['CO', 'H_2O'];
        products = ['CO_2', 'H_2'];
        break;
      case 'DRM':
      default:
        reactants = ['CH_4', 'CO_2'];
        products = ['CO', 'H_2'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Langmuir-Hinshelwood Parameters for $reactionType:', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        const Text('Adsorption Constants (Reactants):'),
        const SizedBox(height: 8),
        Row(
          children: reactants.map((reactant) => 
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'K_{$reactant, $reactionType}',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            )
          ).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Adsorption Constants (Products):'),
        const SizedBox(height: 8),
        Row(
          children: products.map((product) => 
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'K_{$product, $reactionType}',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            )
          ).toList(),
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
