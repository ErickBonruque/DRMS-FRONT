import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/simulator/simulator_screen.dart';
import '../screens/parameter_estimation/parameter_estimation_screen.dart';
import '../screens/configuration_manager/configuration_manager_screen.dart';
import '../../models/simulator_configuration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  SimulatorConfiguration? _pendingConfiguration;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Conteúdo a ser exibido com base na seleção
    Widget contentWidget;
    switch (_selectedIndex) {
      case 0:
        contentWidget = SimulatorScreen(
          initialConfiguration: _pendingConfiguration,
          onConfigurationLoaded: () {
            // Limpar configuração pendente após carregamento
            _pendingConfiguration = null;
          },
        );
        break;
      case 1:
        contentWidget = ConfigurationManagerScreen(
          onNavigateToSimulator: () {
            setState(() {
              _selectedIndex = 0; // Volta para o Simulator
            });
          },
          onLoadConfiguration: (config) {
            // Definir configuração pendente e navegar para o simulador
            setState(() {
              _pendingConfiguration = config;
              _selectedIndex = 0;
            });
            
            // Força uma atualização após um pequeno delay para garantir que a interface seja atualizada
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  // Força uma reconstrução completa
                });
              }
            });
          },
        );
        break;
      case 2:
        contentWidget = const AboutScreen();
        break;
      default:
        contentWidget = const Center(child: Text('Select a menu option'));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRMS'),
        elevation: _selectedIndex == 0 ? 0 : 4, // Remove elevation if in Simulator screen
      ),
      body: Row(
        children: [
          // Menu de navegação lateral fixo
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.play_circle_filled),
                label: Text('Simulator'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_applications),
                label: Text('Configurações'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                label: Text('About'),
              ),
            ],
          ),
          
          // Divisor vertical para separar o menu do conteúdo
          const VerticalDivider(thickness: 1, width: 1),
          
          // Conteúdo principal
          Expanded(
            child: contentWidget,
          ),
        ],
      ),
    );
  }
}
