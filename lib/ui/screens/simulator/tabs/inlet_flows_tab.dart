import 'package:flutter/material.dart';

class InletFlowsTab extends StatefulWidget {
  const InletFlowsTab({super.key});

  @override
  State<InletFlowsTab> createState() => _InletFlowsTabState();
}

class _InletFlowsTabState extends State<InletFlowsTab> {
  final List<String> flowUnits = [
    'm³/s',
    'm³/min',
    'm³/h',
    'mL/s',
    'mL/min',
    'mL/h',
  ];

  String selectedUnitCH4 = 'm³/s';
  String selectedUnitCO2 = 'm³/s';
  String selectedUnitH2O = 'm³/s'; // Adicionando variável para água
  String selectedUnitPressure = 'bar';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowWithDropdown(
            label: 'Inlet Methane Flow',
            unitList: flowUnits,
            selectedValue: selectedUnitCH4,
            onChanged: (value) {
              setState(() {
                selectedUnitCH4 = value!;
              });
            },
          ),
          _rowWithDropdown(
            label: 'Inlet Carbon Dioxide Flow',
            unitList: flowUnits,
            selectedValue: selectedUnitCO2,
            onChanged: (value) {
              setState(() {
                selectedUnitCO2 = value!;
              });
            },
          ),
          _rowWithDropdown(
            label: 'Inlet Water Vapor Flow',
            unitList: flowUnits,
            selectedValue: selectedUnitH2O,
            onChanged: (value) {
              setState(() {
                selectedUnitH2O = value!;
              });
            },
          ),
          _rowWithDropdown(
            label: 'Pressure',
            unitList: const ['bar'],
            selectedValue: selectedUnitPressure,
            onChanged: (value) {
              setState(() {
                selectedUnitPressure = value!;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            '* Flows of methane, carbon dioxide and water vapor at inlet temperature and pressure',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _rowWithDropdown({
    required String label,
    required List<String> unitList,
    required String selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(labelText: label))),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: const InputDecoration(),
              items: unitList
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
