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
import '../../../models/simulator_configuration.dart';
import '../../../services/configuration_service.dart';

class SimulatorScreen extends StatefulWidget {
  final SimulatorConfiguration? initialConfiguration;
  final VoidCallback? onConfigurationLoaded;
  
  const SimulatorScreen({
    super.key,
    this.initialConfiguration,
    this.onConfigurationLoaded,
  });

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  // Por padrão o primeiro tab é o de Inlet Flows
  int _selectedIndex = 0;

  List<Widget> get _tabs => [
    InletFlowsTab(
      initialConfig: _inletFlowsConfig,
      onConfigChanged: (config) {
        _inletFlowsConfig = config;
      },
    ),
    ReactorTab(
      initialConfig: _reactorConfig,
      onConfigChanged: (config) {
        _reactorConfig = config;
      },
    ),
    KineticsTab(
      initialConfig: _kineticsConfig,
      onConfigChanged: (config) {
        _kineticsConfig = config;
      },
    ),
    HeatTab(
      initialConfig: _heatConfig,
      onConfigChanged: (config) {
        _heatConfig = config;
      },
    ),
    SimulateTab(
      initialConfig: _simulateConfig,
      onConfigChanged: (config) {
        _simulateConfig = config;
      },
    ),
    ResultsTab(
      simulationResults: simulationResults, 
      isLoading: isLoading,
      onRunSimulation: _runSimulation,
      onExportData: _exportData,
    ),
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
  
  final ConfigurationService _configService = ConfigurationService();
  
  // Configurações das abas
  InletFlowsConfig _inletFlowsConfig = InletFlowsConfig();
  ReactorConfig _reactorConfig = ReactorConfig();
  KineticsConfig _kineticsConfig = KineticsConfig();
  HeatConfig _heatConfig = HeatConfig();
  SimulateConfig _simulateConfig = SimulateConfig();

  @override
  void initState() {
    super.initState();
    
    // Carregar configuração inicial se fornecida
    if (widget.initialConfiguration != null) {
      print('SimulatorScreen: Carregando configuração inicial: ${widget.initialConfiguration!.name}');
      // Carregar imediatamente para garantir que os dados estejam disponíveis
      loadConfiguration(widget.initialConfiguration!);
      
      // Usar addPostFrameCallback para garantir que a interface seja atualizada após a construção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            // Força uma reconstrução após o carregamento
          });
        }
        
        if (widget.onConfigurationLoaded != null) {
          widget.onConfigurationLoaded!();
        }
      });
    }
  }

  void _runSimulation() async {
    setState(() {
      isLoading = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting simulation...')),
    );
    
    // Chama a API para obter os resultados, n_chunks=5 para testes
    final url = Uri.parse('http://127.0.0.1:5000/results?n_chunks=100');
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

  void _saveConfiguration() async {
    // Dialog para solicitar o nome da configuração
    final nameController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.save, color: Colors.orange.shade600),
            SizedBox(width: 8),
            Text('Salvar Configuração'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digite um nome para esta configuração:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Configuração',
                hintText: 'Ex: Configuração Padrão',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 8),
            Text(
              'Esta configuração salvará todos os valores das abas Inlet, Reactor, Kinetics, Heat e Simulate.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Salvar'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      await _performSaveConfiguration(result);
    }
  }

  Future<void> _performSaveConfiguration(String name) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange.shade600),
                SizedBox(height: 16),
                Text('Salvando configuração...'),
              ],
            ),
          ),
        ),
      );

      // Verificar se o nome já existe
      final nameExists = await _configService.configurationNameExists(name);
      
      // Fechar loading dialog
      if (mounted) Navigator.of(context).pop();
      
      bool shouldProceed = true;
      
      if (nameExists) {
        // Mostrar dialog de confirmação para substituir
        shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.amber.shade600),
                SizedBox(width: 8),
                Text('Configuração Existente'),
              ],
            ),
            content: Text(
              'Já existe uma configuração com o nome "$name". Deseja substituí-la?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Substituir'),
              ),
            ],
          ),
        ) ?? false;
      }
      
      if (!shouldProceed) return;
      
      // Criar configuração com dados atuais das abas
      final config = SimulatorConfiguration(
        id: _configService.generateConfigurationId(),
        name: name,
        createdAt: DateTime.now(),
        inletFlows: _inletFlowsConfig,
        reactor: _reactorConfig,
        kinetics: _kineticsConfig,
        heat: _heatConfig,
        simulate: _simulateConfig,
      );
      
      // Salvar configuração
      final success = await _configService.saveConfiguration(config);
      
      if (success) {
        // Mostrar mensagem de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Configuração "$name" salva com sucesso!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: 80, // Posiciona mais acima da parte inferior
                left: 16,
                right: 16,
              ),
            ),
          );
        }
      } else {
        throw Exception('Falha ao salvar configuração');
      }
      
    } catch (e) {
      // Fechar loading dialog se ainda estiver aberto
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      print('Erro ao salvar configuração: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Erro ao salvar configuração: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: 80, // Posiciona mais acima da parte inferior
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    }
  }

  /// Método público para carregar uma configuração específica
  void loadConfiguration(SimulatorConfiguration config) {
    print('loadConfiguration: Iniciando carregamento da configuração "${config.name}"');
    print('loadConfiguration: InletFlows - Metano: ${config.inletFlows.methanFlow}');
    
    setState(() {
      _inletFlowsConfig = config.inletFlows;
      _reactorConfig = config.reactor;
      _kineticsConfig = config.kinetics;
      _heatConfig = config.heat;
      _simulateConfig = config.simulate;
    });
    
    print('loadConfiguration: Configuração "${config.name}" carregada com sucesso');
    print('loadConfiguration: Estado atualizado - InletFlows metano: ${_inletFlowsConfig.methanFlow}');
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
        actions: _selectedIndex == 5 ? [
          // Botões aparecem apenas na aba Results
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _runSimulation,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Run"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade600.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download),
                label: const Text("Export"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade600.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _saveConfiguration,
                icon: const Icon(Icons.save),
                label: const Text("Salvar Config"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
        ] : null,
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
