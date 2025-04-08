import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class PotenciasPage extends StatefulWidget {
  const PotenciasPage({Key? key}) : super(key: key);

  @override
  State<PotenciasPage> createState() => _PotenciasPageState();
}

class _PotenciasPageState extends State<PotenciasPage> {
  String selectedFormula = 'Fórmula 1';
  List<Map<String, TextEditingController>> dataRows = [
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
            // Section: Kinetics
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
            
            // Selected formula display box
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
            const Text(
              'Experimental Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Lógica para carregar Excel
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text('Load Excel File'),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      dataRows.add({
                        'T': TextEditingController(),
                        'CH4': TextEditingController(),
                        'CO2': TextEditingController(),
                        'Result': TextEditingController(),
                      });
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text('+', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (dataRows.length > 1) {
                      setState(() => dataRows.removeLast());
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text('-', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Data rows
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...dataRows.map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(child: TextField(controller: row['T'], decoration: const InputDecoration(labelText: 'T'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: row['CH4'], decoration: const InputDecoration(labelText: 'CH4'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: row['CO2'], decoration: const InputDecoration(labelText: 'CO2'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: row['Result'], decoration: const InputDecoration(labelText: 'Experimental Results'))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
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
                    _buildDomainInput('A', aMin, aMax),
                    const SizedBox(height: 16),
                    _buildDomainInput('E', eMin, eMax),
                    const SizedBox(height: 16),
                    _buildDomainInput('m', mMin, mMax),
                    const SizedBox(height: 16),
                    _buildDomainInput('n', nMin, nMax),
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
                  // Executar estimativa
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

  Widget _buildDomainInput(String label, TextEditingController minController, TextEditingController maxController) {
    return Row(
      children: [
        SizedBox(
          width: 40, 
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: minController,
            decoration: const InputDecoration(labelText: 'Min'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: maxController,
            decoration: const InputDecoration(labelText: 'Max'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
