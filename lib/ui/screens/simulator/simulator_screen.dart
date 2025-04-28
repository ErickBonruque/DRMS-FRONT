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
  // Por padrão o primeiro tab é o de Inlet Flows
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

  void _runSimulation() {
    // Lógica para executar a simulação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting simulation...')),
    );
  }

  void _exportData() {
    // Lógica para exportar os dados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: _runSimulation, 
              icon: const Icon(Icons.play_arrow),
              label: const Text("Run"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: _exportData, 
              icon: const Icon(Icons.download),
              label: const Text("Export"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
      ),
    );
  }
}
