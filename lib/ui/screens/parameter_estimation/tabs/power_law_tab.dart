import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../widgets/parameter_search_range.dart';
import '../widgets/experimental_data_table.dart';

class PowerLawTab extends StatefulWidget {
  const PowerLawTab({Key? key}) : super(key: key);

  @override
  State<PowerLawTab> createState() => _PowerLawTabState();
}

class _PowerLawTabState extends State<PowerLawTab> {
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
  final TextEditingController mMin = TextEditingController(text: '1');
  final TextEditingController mMax = TextEditingController(text: '1000');
  final TextEditingController nMin = TextEditingController(text: '1');
  final TextEditingController nMax = TextEditingController(text: '1000');

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
            DropdownButton<String>(
              value: selectedFormula,
              itemHeight: 80,
              items: [
                DropdownMenuItem(
                  value: 'Fórmula 1',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Math.tex(
                      r'r = A e^{-E/RT} [CH_4]^m [CO_2]^n',
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Fórmula 2',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Math.tex(
                      r'r = A e^{-E/RT} ([CH_4]^m [CO_2]^n - \frac{[H_2]^p [CO]^q}{K_p})',
                      textStyle: const TextStyle(fontSize: 16),
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
                child: Math.tex(
                  selectedFormula == 'Fórmula 1'
                      ? r'r = A e^{-E/RT} [CH_4]^m [CO_2]^n'
                      : r'r = A e^{-E/RT} ([CH_4]^m [CO_2]^n - \frac{[H_2]^p [CO]^q}{K_p})',
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  mathStyle: MathStyle.display,
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
                    ParameterSearchRange(label: 'm', minController: mMin, maxController: mMax),
                    const SizedBox(height: 16),
                    ParameterSearchRange(label: 'n', minController: nMin, maxController: nMax),
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
}
