import 'package:flutter/material.dart';
import 'simulator_pages/inlet_flows.dart';
import 'simulator_pages/reactor.dart';
import 'simulator_pages/kinetics.dart'; // Changed from kinectis.dart to kinetics.dart
import 'simulator_pages/heat.dart';
import 'simulator_pages/simulate.dart';

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    InletFlowsPage(),
    ReactorPage(),
    KineticsPage(),
    HeatPage(),
    SimulatePage(),
  ];

  final List<String> _titles = [
    'Inlet Flows',
    'Reactor',
    'Kinetics',
    'Heat',
    'Simulate',
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
        Expanded(
          child: _pages[_selectedIndex],
        ),
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Ensures all items are visible
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.input),
              label: 'Inlet',
              tooltip: 'Inlet Flows',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.margin),
              label: 'Reactor',
              tooltip: 'Reactor Properties',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Kinetics',
              tooltip: 'Reaction Kinetics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.thermostat),
              label: 'Heat',
              tooltip: 'Heat Transfer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_filled),
              label: 'Simulate',
              tooltip: 'Run Simulation',
            ),
          ],
        ),
      ],
    );
  }
}
