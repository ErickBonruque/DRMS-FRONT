import 'package:flutter/material.dart';
import '../../../../models/simulator_configuration.dart';

class ReactorTab extends StatefulWidget {
  final ReactorConfig? initialConfig;
  final Function(ReactorConfig)? onConfigChanged;
  
  const ReactorTab({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
  });

  @override
  State<ReactorTab> createState() => _ReactorTabState();
}

class _ReactorTabState extends State<ReactorTab> {
  final List<String> lengthUnits = ['m', 'cm', 'mm'];

  // Controllers para os campos de texto
  late TextEditingController _lengthController;
  late TextEditingController _diameterController;
  late TextEditingController _porosityController;
  late TextEditingController _densityController;
  late TextEditingController _particleDiameterController;

  String selectedLengthUnit = 'm';
  String selectedDiameterUnit = 'm';
  String selectedParticleDiameterUnit = 'm';

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers
    _lengthController = TextEditingController();
    _diameterController = TextEditingController();
    _porosityController = TextEditingController();
    _densityController = TextEditingController();
    _particleDiameterController = TextEditingController();
    
    // Carregar configuração inicial se fornecida
    if (widget.initialConfig != null) {
      _loadConfiguration(widget.initialConfig!);
    }
    
    // Adicionar listeners para notificar mudanças
    _lengthController.addListener(_notifyConfigChanged);
    _diameterController.addListener(_notifyConfigChanged);
    _porosityController.addListener(_notifyConfigChanged);
    _densityController.addListener(_notifyConfigChanged);
    _particleDiameterController.addListener(_notifyConfigChanged);
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _diameterController.dispose();
    _porosityController.dispose();
    _densityController.dispose();
    _particleDiameterController.dispose();
    super.dispose();
  }

  void _loadConfiguration(ReactorConfig config) {
    setState(() {
      _lengthController.text = config.length;
      _diameterController.text = config.diameter;
      _porosityController.text = config.catalystPorosity;
      _densityController.text = config.catalystDensity;
      _particleDiameterController.text = config.particleDiameter;
      selectedLengthUnit = config.lengthUnit;
      selectedDiameterUnit = config.diameterUnit;
      selectedParticleDiameterUnit = config.particleDiameterUnit;
    });
  }

  void _notifyConfigChanged() {
    if (widget.onConfigChanged != null) {
      final config = _getCurrentConfiguration();
      widget.onConfigChanged!(config);
    }
  }

  ReactorConfig _getCurrentConfiguration() {
    return ReactorConfig(
      length: _lengthController.text,
      lengthUnit: selectedLengthUnit,
      diameter: _diameterController.text,
      diameterUnit: selectedDiameterUnit,
      catalystPorosity: _porosityController.text,
      catalystDensity: _densityController.text,
      particleDiameter: _particleDiameterController.text,
      particleDiameterUnit: selectedParticleDiameterUnit,
    );
  }

  void _onUnitChanged() {
    _notifyConfigChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowWithDropdown(
            label: 'Reactor Length',
            controller: _lengthController,
            selectedValue: selectedLengthUnit,
            onChanged: (value) {
              setState(() {
                selectedLengthUnit = value!;
              });
              _onUnitChanged();
            },
          ),
          _rowWithDropdown(
            label: 'Reactor Diameter',
            controller: _diameterController,
            selectedValue: selectedDiameterUnit,
            onChanged: (value) {
              setState(() {
                selectedDiameterUnit = value!;
              });
              _onUnitChanged();
            },
          ),
          _textOnlyField('Catalyst Porosity', _porosityController),
          _textOnlyField('Catalyst Density [kg/m³]', _densityController),
          _rowWithDropdown(
            label: 'Catalyst Particle Diameter',
            controller: _particleDiameterController,
            selectedValue: selectedParticleDiameterUnit,
            onChanged: (value) {
              setState(() {
                selectedParticleDiameterUnit = value!;
              });
              _onUnitChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _rowWithDropdown({
    required String label,
    required TextEditingController controller,
    required String selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: label),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              items: lengthUnits
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
