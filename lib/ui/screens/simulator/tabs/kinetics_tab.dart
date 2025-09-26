import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/power_law_model.dart';
import '../models/eley_rideal_model.dart';
import '../models/langmuir_hinshelwood_model.dart';
import '../../../../constants/kinetics_constants.dart';
import '../../../../models/simulator_configuration.dart';

class KineticsTab extends StatefulWidget {
  final KineticsConfig? initialConfig;
  final Function(KineticsConfig)? onConfigChanged;
  
  const KineticsTab({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
  });

  @override
  State<KineticsTab> createState() => KineticsTabState();
}

class KineticsTabState extends State<KineticsTab> {
  // Opções de cinética disponíveis
  // (Power-Law, Eley-Rideal, Langmuir-Hinshelwood)
  final List<String> kineticsOptions = [
    'Power-Law',
    'Eley-Rideal',
    'Langmuir-Hinshelwood',
  ];

  // Mapa de cinéticas selecionadas para cada reação
  Map<String, String> selectedKineticsForReaction = {
    'SMR': 'Power-Law',
    'DRM': 'Power-Law',
    'WGS': 'Power-Law',
  };

  String selectedRateUnit = KineticsConstants.rateUnits[0];
  
  // Seleção de que reação o usuario quer fazer
  Map<String, bool> selectedReactions = {
    'SMR': false,
    'DRM': true,  // Por padrão, DRM está selecionada
    'WGS': false,
  };

  // Bagulho reversivel para cada reação
  Map<String, bool> isReversible = {
    'SMR': false,
    'DRM': false,
    'WGS': false,
  };

  // Equações em LaTeX para cada reação
  final Map<String, String> reactionEquations = {
    'SMR': r'\text{CH}_4 + \text{H}_2\text{O} \rightleftharpoons \text{CO} + 3\text{H}_2',
    'DRM': r'\text{CH}_4 +\text{CO}_2 \rightleftharpoons 2\text{CO} + 2\text{H}_2',
    'WGS': r'\text{CO} +\text{H}_2\text{O} \rightleftharpoons \text{CO}_2 + \text{H}_2',
  };

  // Reação nomes para exibição
  final Map<String, String> reactionNames = {
    'SMR': 'Steam Methane Reforming',
    'DRM': 'Dry Methane Reforming',
    'WGS': 'Water-Gas-Shift',
  };

  // Controllers para os parâmetros dos modelos
  Map<String, TextEditingController> _parameterControllers = {};

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers para parâmetros
    _initializeParameterControllers();
    
    // Carregar configuração inicial se fornecida
    if (widget.initialConfig != null) {
      _loadConfiguration(widget.initialConfig!);
    }
    
    // Adicionar listeners para notificar mudanças
    _parameterControllers.values.forEach((controller) {
      controller.addListener(_notifyConfigChanged);
    });
  }

  @override
  void dispose() {
    _parameterControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeParameterControllers() {
    // Parâmetros comuns para todos os modelos
    final reactions = ['SMR', 'DRM', 'WGS'];
    
    for (final reaction in reactions) {
      // Parâmetros básicos (A, E)
      _parameterControllers['A_$reaction'] = TextEditingController();
      _parameterControllers['E_$reaction'] = TextEditingController();
      
      // Power-Law: alpha, beta, K_eq
      _parameterControllers['alpha_$reaction'] = TextEditingController();
      _parameterControllers['beta_$reaction'] = TextEditingController();
      _parameterControllers['K_eq_$reaction'] = TextEditingController();
      
      // Eley-Rideal: constantes de adsorção específicas
      switch (reaction) {
        case 'SMR':
          _parameterControllers['K_CH_4, SMR'] = TextEditingController();
          _parameterControllers['K_H_2O, SMR'] = TextEditingController();
          break;
        case 'DRM':
          _parameterControllers['K_CH_4, DRM'] = TextEditingController();
          _parameterControllers['K_CO_2, DRM'] = TextEditingController();
          break;
        case 'WGS':
          _parameterControllers['K_CO, WGS'] = TextEditingController();
          _parameterControllers['K_H_2O, WGS'] = TextEditingController();
          break;
      }
      
      // Langmuir-Hinshelwood: constantes para reagentes e produtos
      switch (reaction) {
        case 'SMR':
          _parameterControllers['K_CH4_$reaction'] = TextEditingController();
          _parameterControllers['K_H2O_$reaction'] = TextEditingController();
          _parameterControllers['K_CO_$reaction'] = TextEditingController();
          _parameterControllers['K_H2_$reaction'] = TextEditingController();
          break;
        case 'DRM':
          _parameterControllers['K_CH4_$reaction'] = TextEditingController();
          _parameterControllers['K_CO2_$reaction'] = TextEditingController();
          _parameterControllers['K_CO_$reaction'] = TextEditingController();
          _parameterControllers['K_H2_$reaction'] = TextEditingController();
          break;
        case 'WGS':
          _parameterControllers['K_CO_$reaction'] = TextEditingController();
          _parameterControllers['K_H2O_$reaction'] = TextEditingController();
          _parameterControllers['K_CO2_$reaction'] = TextEditingController();
          _parameterControllers['K_H2_$reaction'] = TextEditingController();
          break;
      }
    }
  }

  void _loadConfiguration(KineticsConfig config) {
    setState(() {
      selectedReactions = Map<String, bool>.from(config.selectedReactions);
      selectedKineticsForReaction = Map<String, String>.from(config.selectedKineticsForReaction);
      isReversible = Map<String, bool>.from(config.isReversible);
      selectedRateUnit = config.selectedRateUnit;
      
      // Carregar parâmetros nos controllers
      config.modelParameters.forEach((param, value) {
        if (_parameterControllers.containsKey(param)) {
          _parameterControllers[param]!.text = value;
        }
      });
    });
  }

  void _notifyConfigChanged() {
    if (widget.onConfigChanged != null) {
      final config = _getCurrentConfiguration();
      widget.onConfigChanged!(config);
    }
  }

  KineticsConfig _getCurrentConfiguration() {
    // Coletar parâmetros dos controllers
    final Map<String, String> modelParameters = {};
    _parameterControllers.forEach((param, controller) {
      if (controller.text.isNotEmpty) {
        modelParameters[param] = controller.text;
      }
    });

    return KineticsConfig(
      selectedReactions: selectedReactions,
      selectedKineticsForReaction: selectedKineticsForReaction,
      isReversible: isReversible,
      selectedRateUnit: selectedRateUnit,
      modelParameters: modelParameters,
    );
  }

  void _onReactionChanged(String reaction, bool? value) {
    setState(() {
      selectedReactions[reaction] = value ?? false;
    });
    _notifyConfigChanged();
  }

  void _onKineticsModelChanged(String reaction, String? value) {
    setState(() {
      selectedKineticsForReaction[reaction] = value ?? 'Power-Law';
    });
    _notifyConfigChanged();
  }

  void _onReversibilityChanged(String reaction, bool? value) {
    setState(() {
      isReversible[reaction] = value ?? false;
    });
    _notifyConfigChanged();
  }

  void _onRateUnitChanged(String? value) {
    setState(() {
      selectedRateUnit = value ?? KineticsConstants.rateUnits[0];
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
            const SizedBox(height: 24),
            _buildReactionSelectionSection(),
            const SizedBox(height: 32),
            // Construir seções de reação com base na seleção do usuário
            // Usar o método map para criar uma lista de widgets
            ...selectedReactions.entries
                .where((entry) => entry.value)
                .map((entry) => _buildReactionSection(entry.key))
                .expand((widget) => [widget, const SizedBox(height: 24)])
                .toList()..removeLast(),
            const SizedBox(height: 25),
            Row(
              children: [
                _buildRateUnitDropdown(),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '*Energy of Activation (E) in J/mol',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSelectionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Reactions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...selectedReactions.keys.map((reaction) => CheckboxListTile(
              title: Text(reactionNames[reaction]!),
              value: selectedReactions[reaction],
              onChanged: (value) => _onReactionChanged(reaction, value),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSection(String reactionType) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: _buildReactionExpansionTile(reactionType),
    );
  }

  Widget _buildReactionExpansionTile(String reactionType) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          reactionNames[reactionType]!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        collapsedBackgroundColor: Colors.grey.shade50,
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Reação equação e reversibilidade checkbox
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Math.tex(
                          reactionEquations[reactionType]!,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isReversible[reactionType],
                          onChanged: (value) => _onReversibilityChanged(reactionType, value),
                        ),
                        const Text('Reversible'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Dropdown para selecionar o modelo cinético
                const Text(
                  'Kinetics Model:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedKineticsForReaction[reactionType],
                  items: kineticsOptions
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (value) => _onKineticsModelChanged(reactionType, value),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // parametro de ativação
                _buildKineticsModelForReaction(reactionType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKineticsModelForReaction(String reactionType) {
    // Usar a classe correspondente com base na cinética selecionada
    switch (selectedKineticsForReaction[reactionType]) {
      case 'Eley-Rideal':
        return EleyRidealModel(
          isReversible: isReversible[reactionType]!,
          reactionType: reactionType,
          controllers: _parameterControllers,
        );
      case 'Langmuir-Hinshelwood':
        return LangmuirHinshelwoodModel(
          isReversible: isReversible[reactionType]!,
          reactionType: reactionType,
          controllers: _parameterControllers,
        );
      case 'Power-Law':
      default:
        return PowerLawModel(
          isReversible: isReversible[reactionType]!,
          reactionType: reactionType,
          controllers: _parameterControllers,
        );
    }
  }

  Widget _buildRateUnitDropdown() {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: selectedRateUnit,
        items: KineticsConstants.rateUnits
            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
            .toList(),
        onChanged: (value) => _onRateUnitChanged(value),
        decoration: const InputDecoration(),
      ),
    );
  }
}
