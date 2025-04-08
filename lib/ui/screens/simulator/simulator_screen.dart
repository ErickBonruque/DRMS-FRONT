import 'package:flutter/material.dart';
import 'tabs/inlet_flows_tab.dart';
import 'tabs/reactor_tab.dart';
import 'tabs/kinetics_tab.dart';
import 'tabs/heat_tab.dart';
import 'tabs/simulate_tab.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  // Default to 0 (inlet flows) when the page opens
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    InletFlowsTab(),
    ReactorTab(),
    KineticsTab(),
    HeatTab(),
    SimulateTab(),
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
