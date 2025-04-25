import 'package:flutter/material.dart';
import 'tabs/power_law_tab.dart';
import 'tabs/eley_rideal_tab.dart';
import 'tabs/langmuir_hinshelwood_tab.dart';

class ParameterEstimationScreen extends StatefulWidget {
  const ParameterEstimationScreen({super.key});

  @override
  State<ParameterEstimationScreen> createState() => _ParameterEstimationScreenState();
}

class _ParameterEstimationScreenState extends State<ParameterEstimationScreen> {
  // Padrão igual a 0 para Power Law
  // 1 para Eley-Rideal e 2 para Langmuir-Hinshelwood
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    PowerLawTab(),
    EleyRidealTab(),
    LangmuirHinshelwoodTab(),
  ];

  final List<String> _titles = [
    'Power Law',
    'Eley-Rideal',
    'Langmuir-Hinshelwood',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title bar for the selected page
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            _titles[_selectedIndex],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Main content
        Expanded(
          child: _tabs[_selectedIndex],
        ),
        // Bottom navigation
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Ensures all items are visible
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.functions),
              label: 'Power Law',
              tooltip: 'Power Law Model',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Eley-Rideal',
              tooltip: 'Eley-Rideal Model',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech),
              label: 'L-H',
              tooltip: 'Langmuir-Hinshelwood Model',
            ),
          ],
        ),
      ],
    );
  }
}
