import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../models/simulator_configuration.dart';

class SimulateTab extends StatefulWidget {
  final SimulateConfig? initialConfig;
  final Function(SimulateConfig)? onConfigChanged;
  
  const SimulateTab({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
  });

  @override
  State<SimulateTab> createState() => _SimulateTabState();
}

class _SimulateTabState extends State<SimulateTab> {
  // Mass balance equation terms with their LaTeX representations
  final Map<String, Map<String, dynamic>> massBalanceTerms = {
    'Accumulation Rate': {
      'equation': r'\frac{\partial}{\partial t} C_j',
      'selected': true,
    },
    'Convection': {
      'equation': r'-\frac{\partial}{\partial z}(v_z C_j)',
      'selected': true,
    },
    'Axial Diffusion': {
      'equation': r'D_{L,j} \frac{\partial^2}{\partial z^2} C_j',
      'selected': true,
    },
    'Reaction': {
      'equation': r'\frac{1}{\varepsilon} \nu_j \rho_{cat} R',
      'selected': true,
    },
    'Radial Diffusion': {
      'equation': r'D_{L,j} \left( \frac{\partial^2}{\partial r^2} C_j + \frac{1}{r} \frac{\partial}{\partial r} C_j \right)',
      'selected': false,
    },
  };

  // Energy balance equation terms with their LaTeX representations
  final Map<String, Map<String, dynamic>> energyBalanceTerms = {
    'Accumulation Rate': {
      'equation': r'\frac{\partial}{\partial t} T',
      'selected': true,
    },
    'Convection': {
      'equation': r'-\varepsilon \rho_g C_{p,mix} \frac{\partial}{\partial z} T',
      'selected': true,
    },
    'Axial Diffusion': {
      'equation': r'\varepsilon \lambda_L \frac{\partial^2}{\partial z^2} T',
      'selected': true,
    },
    'Reaction': {
      'equation': r'-\Delta H_R \rho_{cat} R',
      'selected': true,
    },
    'Radial Diffusion': {
      'equation': r'\lambda_L \left( \frac{\partial^2}{\partial z^2} T + \frac{1}{r} \frac{\partial}{\partial z} T \right)',
      'selected': false,
    },
    'Without Radial Diffusion (Thermal)': {
      'equation': r'-\frac{4 U_{TC}}{D_t}(T-T_w)',
      'selected': false,
    },
  };

  // Controllers para os campos de texto
  late TextEditingController _minTimeStepController;
  late TextEditingController _maxTimeStepController;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers
    _minTimeStepController = TextEditingController();
    _maxTimeStepController = TextEditingController();
    
    // Carregar configuração inicial se fornecida
    if (widget.initialConfig != null) {
      _loadConfiguration(widget.initialConfig!);
    }
    
    // Adicionar listeners para notificar mudanças
    _minTimeStepController.addListener(_notifyConfigChanged);
    _maxTimeStepController.addListener(_notifyConfigChanged);
  }

  @override
  void dispose() {
    _minTimeStepController.dispose();
    _maxTimeStepController.dispose();
    super.dispose();
  }

  void _loadConfiguration(SimulateConfig config) {
    setState(() {
      // Carregar termos do balanço de massa
      config.massBalanceTerms.forEach((term, selected) {
        if (massBalanceTerms.containsKey(term)) {
          massBalanceTerms[term]!['selected'] = selected;
        }
      });
      
      // Carregar termos do balanço de energia  
      config.energyBalanceTerms.forEach((term, selected) {
        if (energyBalanceTerms.containsKey(term)) {
          energyBalanceTerms[term]!['selected'] = selected;
        }
      });
      
      // Carregar parâmetros de simulação
      _minTimeStepController.text = config.simulationParameters['minTimeStep'] ?? '';
      _maxTimeStepController.text = config.simulationParameters['maxTimeStep'] ?? '';
    });
  }

  void _notifyConfigChanged() {
    if (widget.onConfigChanged != null) {
      final config = _getCurrentConfiguration();
      widget.onConfigChanged!(config);
    }
  }

  SimulateConfig _getCurrentConfiguration() {
    // Coletar termos do balanço de massa
    final Map<String, bool> massBalance = {};
    massBalanceTerms.forEach((term, data) {
      massBalance[term] = data['selected'] as bool;
    });
    
    // Coletar termos do balanço de energia
    final Map<String, bool> energyBalance = {};
    energyBalanceTerms.forEach((term, data) {
      energyBalance[term] = data['selected'] as bool;
    });
    
    // Coletar parâmetros de simulação
    final Map<String, String> simParams = {
      'minTimeStep': _minTimeStepController.text,
      'maxTimeStep': _maxTimeStepController.text,
    };

    return SimulateConfig(
      massBalanceTerms: massBalance,
      energyBalanceTerms: energyBalance,
      simulationParameters: simParams,
    );
  }

  void _onMassBalanceTermChanged(String term, bool? value) {
    setState(() {
      massBalanceTerms[term]!['selected'] = value ?? false;
    });
    _notifyConfigChanged();
  }

  void _onEnergyBalanceTermChanged(String term, bool? value) {
    setState(() {
      energyBalanceTerms[term]!['selected'] = value ?? false;
    });
    _notifyConfigChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeStepsRow(),
            const SizedBox(height: 32),
            _buildEquationSelectionSection('Mass Balance', massBalanceTerms),
            const SizedBox(height: 24),
            _buildEquationSelectionSection('Energy Balance', energyBalanceTerms),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeStepsRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minTimeStepController,
            decoration: const InputDecoration(labelText: 'Minimum time step'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: TextField(
            controller: _maxTimeStepController,
            decoration: const InputDecoration(labelText: 'Maximum time step'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildEquationSelectionSection(String title, Map<String, Map<String, dynamic>> terms) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...terms.entries.map((entry) => _buildEquationCheckbox(
              entry.key, 
              entry.value['equation'], 
              entry.value['selected'],
              title,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEquationCheckbox(String term, String equation, bool isSelected, String balanceType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              if (balanceType == 'Mass Balance') {
                _onMassBalanceTermChanged(term, value);
              } else {
                _onEnergyBalanceTermChanged(term, value);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    term,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Math.tex(
                      equation,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
