import 'package:flutter/material.dart';

class SimulateTab extends StatelessWidget {
  const SimulateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _row('Final time - seconds', 'Axial partitions'),
          _row('Minimum time step', 'Maximum time step'),
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Run'),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Export'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _row(String label1, String label2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(labelText: label1))),
          const SizedBox(width: 24),
          Expanded(child: TextField(decoration: InputDecoration(labelText: label2))),
        ],
      ),
    );
  }
}
