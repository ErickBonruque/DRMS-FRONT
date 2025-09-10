import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Added import for http package
import 'dart:convert';
import 'dart:math';
import 'tabs/inlet_flows_tab.dart';
import 'tabs/reactor_tab.dart';
import 'tabs/kinetics_tab.dart';
import 'tabs/heat_tab.dart';
import 'tabs/simulate_tab.dart';
import 'tabs/results_tab.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  // Por padrão o primeiro tab é o de Inlet Flows
  int _selectedIndex = 0;

  List<Widget> get _tabs => [
    const InletFlowsTab(),
    const ReactorTab(),
    const KineticsTab(),
    const HeatTab(),
    const SimulateTab(),
    ResultsTab(simulationResults: simulationResults, isLoading: isLoading),
  ];

  final List<String> _titles = [
    'Inlet Flows',
    'Reactor',
    'Kinetics',
    'Heat',
    'Simulate',
    'Results',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Map<String, dynamic>? simulationResults;
  bool isLoading = false;

  void _runSimulation() async {
    setState(() {
      isLoading = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting simulation...')),
    );
    
    // Chama a API para obter os resultados, n_chunks=5 para testes
    final url = Uri.parse('http://127.0.0.1:5000/results?n_chunks=5');
    try {
      print('Calling API at: $url');
      final response = await http.get(url);
      print('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Simulation data retrieved successfully.');
        print('Response body length: ${response.body.length}');
        print('Response body preview: ${response.body.substring(0, min(200, response.body.length))}');
        
        try {
          // Decodifica a resposta JSON
          final data = json.decode(response.body);
          print('JSON decoded successfully. Keys: ${data.keys.toList()}');
          
          if (data.containsKey('CA_history')) {
            print('CA_history found. Length: ${data['CA_history'].length}');
            if (data['CA_history'].isNotEmpty) {
              print('First iteration shape: ${data['CA_history'][0].length} x ${data['CA_history'][0][0].length}');
            }
          } else {
            print('CA_history not found in response data');
          }
          
          setState(() {
            simulationResults = data;
            isLoading = false;
            // Navega para a aba de resultados
            _selectedIndex = 5; 
          });
        } catch (e) {
          print('Error decoding JSON: $e');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing response data: $e')),
          );
        }
      } else {
        print('Error retrieving simulation data: ${response.body}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to retrieve simulation data')),
        );
      }
    } catch (e) {
      print('Connection error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _exportData() {
    // Lógica para exportar os dados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug information
    print('Building SimulatorScreen with _selectedIndex: $_selectedIndex');
    print('simulationResults is ${simulationResults != null ? "not null" : "null"}');
    if (simulationResults != null) {
      print('simulationResults keys: ${simulationResults!.keys.toList()}');
    }
    
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
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Results',
                tooltip: 'Simulation Results',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
