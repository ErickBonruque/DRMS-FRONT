import 'package:flutter/material.dart';
import 'about.dart';
import 'simulator_page.dart';
import 'parameter_estimation_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
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
    Widget contentWidget;
    switch (_selectedIndex) {
      case 0:
        contentWidget = const SimulatorPage();
        break;
      case 1:
        contentWidget = const ParameterEstimationPage();
        break;
      case 2:
        contentWidget = const AboutPage();
        break;
      default:
        contentWidget = const Center(child: Text('Select a menu option'));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRMS'),
      ),
      body: Row(
        children: [
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
                icon: Icon(Icons.tune),
                label: Text('Parameter Estimation'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                label: Text('About'),
              ),
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),
          
          Expanded(
            child: contentWidget,
          ),
        ],
      ),
    );
  }
}
