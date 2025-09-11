import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/simulator/simulator_screen.dart';
import '../screens/parameter_estimation/parameter_estimation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
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
        contentWidget = const SimulatorScreen();
        break;
      // case 1: Parameter Estimation temporariamente removido
      //   contentWidget = const ParameterEstimationScreen();
      //   break;
      case 1:
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
              // NavigationRailDestination( // Parameter Estimation temporariamente removido
              //   icon: Icon(Icons.tune),
              //   label: Text('Parameter Estimation'),
              // ),
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
