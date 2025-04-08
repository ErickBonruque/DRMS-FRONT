import 'package:flutter/material.dart';

class ExperimentalDataTable extends StatelessWidget {
  final List<Map<String, TextEditingController>> dataRows;
  final VoidCallback onAddRow;
  final VoidCallback onRemoveRow;

  const ExperimentalDataTable({
    Key? key,
    required this.dataRows,
    required this.onAddRow,
    required this.onRemoveRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Experimental Data',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // Logic to load Excel file
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text('Load Excel File'),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: onAddRow,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text('+', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onRemoveRow,
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
      ],
    );
  }
}
