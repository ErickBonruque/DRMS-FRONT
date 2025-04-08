import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../widgets/parameter_search_range.dart';
import '../widgets/experimental_data_table.dart';

class LangmuirHinshelwoodTab extends StatefulWidget {
  const LangmuirHinshelwoodTab({Key? key}) : super(key: key);

  @override
  State<LangmuirHinshelwoodTab> createState() => _LangmuirHinshelwoodTabState();
}

class _LangmuirHinshelwoodTabState extends State<LangmuirHinshelwoodTab> {
  String selectedFormula = 'Fórmula 1';
  final List<Map<String, TextEditingController>> dataRows = [
    {
      'T': TextEditingController(),
      'CH4': TextEditingController(),
      'CO2': TextEditingController(),
      'Result': TextEditingController(),
    }
  ];

  final TextEditingController aMin = TextEditingController(text: '1');
  final TextEditingController aMax = TextEditingController(text: '1000');
  final TextEditingController eMin = TextEditingController(text: '1');
  final TextEditingController eMax = TextEditingController(text: '1000');
  final TextEditingController kCh4Min = TextEditingController(text: '1');
  final TextEditingController kCh4Max = TextEditingController(text: '1000');
  final TextEditingController kCo2Min = TextEditingController(text: '1');
  final TextEditingController kCo2Max = TextEditingController(text: '1000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kinetics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFormula,
                itemHeight: 80, // Add height for dropdown items
                items: [
                  DropdownMenuItem(
                    value: 'Fórmula 1',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000, minHeight: 56),
                        child: Math.tex(
                          r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} [CH_4][CO_2]}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}',
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Fórmula 2',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000, minHeight: 56),
                        child: Math.tex(
                          r'r = \frac{A e^{\frac{-E}{RT}} (K_{CH_4} K_{CO_2} [CH_4][CO_2])}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2] + K_{H_2}[H_2] + K_{CO}[CO])^4}',
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Fórmula 3',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000, minHeight: 56),
                        child: Math.tex(
                          r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} \left( [CH_4][CO_2] - \frac{[H_2]^2[CO]^2}{K_p} \right)}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}',
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Fórmula 4',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000, minHeight: 56),
                        child: Math.tex(
                          r'r = \frac{A e^{\frac{-E}{RT}} \left( K_{CH_4} K_{CO_2} [CH_4][CO_2] - \frac{[H_2]^2[CO]^2 K_{H_2}^2 K_{CO}^2}{K_p} \right)}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2] + K_{H_2}[H_2] + K_{CO}[CO])^4}',
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedFormula = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Math.tex(
                    _getSelectedFormulaLatex(),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    mathStyle: MathStyle.display,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
            
            // Section: Experimental Data
            ExperimentalDataTable(
              dataRows: dataRows,
              onAddRow: () {
                setState(() {
                  dataRows.add({
                    'T': TextEditingController(),
                    'CH4': TextEditingController(),
                    'CO2': TextEditingController(),
                    'Result': TextEditingController(),
                  });
                });
              },
              onRemoveRow: () {
                if (dataRows.length > 1) {
                  setState(() => dataRows.removeLast());
                }
              },
            ),

            const SizedBox(height: 30),
            
            // Section: Estimation Method
            const Text(
              'Estimation Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            DropdownButton<String>(
              value: 'Particle Swarm',
              items: const [
                DropdownMenuItem(
                  value: 'Particle Swarm',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Particle Swarm', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
              onChanged: (_) {},
            ),

            const SizedBox(height: 30),
            
            // Section: Initial Search Domain
            const Text(
              'Initial Search Domain',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ParameterSearchRange(label: 'A', minController: aMin, maxController: aMax),
                    const SizedBox(height: 16),
                    ParameterSearchRange(label: 'E', minController: eMin, maxController: eMax),
                    const SizedBox(height: 16),
                    ParameterSearchRange(
                      label: 'K_{CH_4}', 
                      minController: kCh4Min, 
                      maxController: kCh4Max,
                      useMathText: true,
                    ),
                    const SizedBox(height: 16),
                    ParameterSearchRange(
                      label: 'K_{CO_2}', 
                      minController: kCo2Min, 
                      maxController: kCo2Max,
                      useMathText: true,
                    ),
                    
                    // Add additional parameters based on the formula
                    if (selectedFormula == 'Fórmula 2' || selectedFormula == 'Fórmula 4') ...[
                      const SizedBox(height: 16),
                      ParameterSearchRange(
                        label: 'K_{H_2}', 
                        minController: TextEditingController(text: '1'), 
                        maxController: TextEditingController(text: '1000'),
                        useMathText: true,
                      ),
                      const SizedBox(height: 16),
                      ParameterSearchRange(
                        label: 'K_{CO}', 
                        minController: TextEditingController(text: '1'), 
                        maxController: TextEditingController(text: '1000'),
                        useMathText: true,
                      ),
                    ],
                    
                    if (selectedFormula == 'Fórmula 3' || selectedFormula == 'Fórmula 4') ...[
                      const SizedBox(height: 16),
                      ParameterSearchRange(
                        label: 'K_p', 
                        minController: TextEditingController(text: '1'), 
                        maxController: TextEditingController(text: '1000'),
                        useMathText: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),
            
            // Run Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Execute estimation
                },
                child: const Text('Run'),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getSelectedFormulaLatex() {
    switch (selectedFormula) {
      case 'Fórmula 1':
        return r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} [CH_4][CO_2]}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}';
      case 'Fórmula 2':
        return r'r = \frac{A e^{\frac{-E}{RT}} (K_{CH_4} K_{CO_2} [CH_4][CO_2])}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2] + K_{H_2}[H_2] + K_{CO}[CO])^4}';
      case 'Fórmula 3':
        return r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} \left( [CH_4][CO_2] - \frac{[H_2]^2[CO]^2}{K_p} \right)}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}';
      case 'Fórmula 4':
        return r'r = \frac{A e^{\frac{-E}{RT}} \left( K_{CH_4} K_{CO_2} [CH_4][CO_2] - \frac{[H_2]^2[CO]^2 K_{H_2}^2 K_{CO}^2}{K_p} \right)}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2] + K_{H_2}[H_2] + K_{CO}[CO])^4}';
      default:
        return r'r = \frac{A e^{\frac{-E}{RT}} K_{CH_4} K_{CO_2} [CH_4][CO_2]}{(1 + K_{CH_4}[CH_4] + K_{CO_2}[CO_2])^2}';
    }
  }
}
