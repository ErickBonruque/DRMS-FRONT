import 'package:flutter/material.dart';

class ReactorPage extends StatefulWidget {
  const ReactorPage({super.key});

  @override
  State<ReactorPage> createState() => _ReactorPageState();
}

class _ReactorPageState extends State<ReactorPage> {
  final List<String> lengthUnits = ['m', 'cm', 'mm'];

  String selectedLengthUnit = 'm';
  String selectedDiameterUnit = 'm';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowWithDropdown(
            label: 'Length',
            selectedValue: selectedLengthUnit,
            onChanged: (value) {
              setState(() {
                selectedLengthUnit = value!;
              });
            },
          ),
          _rowWithDropdown(
            label: 'Diameter',
            selectedValue: selectedDiameterUnit,
            onChanged: (value) {
              setState(() {
                selectedDiameterUnit = value!;
              });
            },
          ),
          _textOnlyField('Porosity'),
          _textOnlyField('Catalyst Density [kg/m³]'),
        ],
      ),
    );
  }

  Widget _rowWithDropdown({
    required String label,
    required String selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: label),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              items: lengthUnits
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

  Widget _textOnlyField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
