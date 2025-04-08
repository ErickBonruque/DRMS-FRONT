import 'package:flutter/material.dart';
import 'parameter_estimation_pages/potencias_page.dart';
import 'parameter_estimation_pages/eley_rideal_page.dart';
import 'parameter_estimation_pages/langmuir_hinshelwood_page.dart';

class ParameterEstimationPage extends StatefulWidget {
  const ParameterEstimationPage({super.key});

  @override
  State<ParameterEstimationPage> createState() => _ParameterEstimationPageState();
}

class _ParameterEstimationPageState extends State<ParameterEstimationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PotenciasPage(),
    EleyRidealPage(),
    LangmuirHinshelwoodPage(),
  ];

  final List<String> _titles = [
    'Potências',
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            _titles[_selectedIndex],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Main content
        Expanded(
          child: _pages[_selectedIndex],
        ),
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.functions),
              label: 'Potências',
              tooltip: 'Modelo de Potências',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Eley-Rideal',
              tooltip: 'Modelo Eley-Rideal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech),
              label: 'L-H',
              tooltip: 'Modelo Langmuir-Hinshelwood',
            ),
          ],
        ),
      ],
    );
  }
}
