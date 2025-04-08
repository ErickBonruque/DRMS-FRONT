import 'package:flutter/material.dart';

class HeatPage extends StatefulWidget {
  const HeatPage({super.key});

  @override
  State<HeatPage> createState() => _HeatPageState();
}

class _HeatPageState extends State<HeatPage> {
  final List<String> temperatureUnits = ['K', '°C', '°F'];
  
  String selectedInletTempUnit = 'K';
  String selectedExternalTempUnit = 'K';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _fixedUnitRow('Overall Heat Transfer Coefficient (Utc)', 'kJ/m³sK'),
          _rowWithUnitOptions(
            label: 'Inlet Temperature',
            unitList: temperatureUnits,
            selectedValue: selectedInletTempUnit,
            onChanged: (value) {
              setState(() {
                selectedInletTempUnit = value!;
              });
            },
          ),
          _rowWithUnitOptions(
            label: 'External Temperature',
            unitList: temperatureUnits,
            selectedValue: selectedExternalTempUnit,
            onChanged: (value) {
              setState(() {
                selectedExternalTempUnit = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _fixedUnitRow(String label, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(labelText: label))),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: DropdownButtonFormField(
              value: unit,
              items: [DropdownMenuItem(value: unit, child: Text(unit))],
              onChanged: (_) {},
              decoration: const InputDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWithUnitOptions({
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
            width: 100,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              items: unitList
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(),
            ),
          ),
        ],
      ),
    );
  }
}
