import 'package:flutter/material.dart';
import '../../../../models/simulator_configuration.dart';

class InletFlowsTab extends StatefulWidget {
  final InletFlowsConfig? initialConfig;
  final Function(InletFlowsConfig)? onConfigChanged;
  
  const InletFlowsTab({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
  });

  @override
  State<InletFlowsTab> createState() => _InletFlowsTabState();
}

class _InletFlowsTabState extends State<InletFlowsTab> {
  final List<String> flowUnits = [
    'm³/s',
    'm³/min',
    'm³/h',
    'mL/s',
    'mL/min',
    'mL/h',
  ];

  // Controllers para os campos de texto
  late TextEditingController _methaneController;
  late TextEditingController _co2Controller;
  late TextEditingController _h2oController;
  late TextEditingController _pressureController;

  String selectedUnitCH4 = 'm³/s';
  String selectedUnitCO2 = 'm³/s';
  String selectedUnitH2O = 'm³/s';
  String selectedUnitPressure = 'bar';

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers
    _methaneController = TextEditingController();
    _co2Controller = TextEditingController();
    _h2oController = TextEditingController();
    _pressureController = TextEditingController();
    
    // Carregar configuração inicial se fornecida
    if (widget.initialConfig != null) {
      _loadConfiguration(widget.initialConfig!);
    }
    
    // Adicionar listeners para notificar mudanças
    _methaneController.addListener(_notifyConfigChanged);
    _co2Controller.addListener(_notifyConfigChanged);
    _h2oController.addListener(_notifyConfigChanged);
    _pressureController.addListener(_notifyConfigChanged);
  }

  @override
  void dispose() {
    _methaneController.dispose();
    _co2Controller.dispose();
    _h2oController.dispose();
    _pressureController.dispose();
    super.dispose();
  }

  void _loadConfiguration(InletFlowsConfig config) {
    setState(() {
      _methaneController.text = config.methanFlow;
      _co2Controller.text = config.co2Flow;
      _h2oController.text = config.h2oFlow;
      _pressureController.text = config.pressure;
      selectedUnitCH4 = config.methaneFlowUnit;
      selectedUnitCO2 = config.co2FlowUnit;
      selectedUnitH2O = config.h2oFlowUnit;
      selectedUnitPressure = config.pressureUnit;
    });
  }

  void _notifyConfigChanged() {
    if (widget.onConfigChanged != null) {
      final config = _getCurrentConfiguration();
      widget.onConfigChanged!(config);
    }
  }

  InletFlowsConfig _getCurrentConfiguration() {
    return InletFlowsConfig(
      methanFlow: _methaneController.text,
      methaneFlowUnit: selectedUnitCH4,
      co2Flow: _co2Controller.text,
      co2FlowUnit: selectedUnitCO2,
      h2oFlow: _h2oController.text,
      h2oFlowUnit: selectedUnitH2O,
      pressure: _pressureController.text,
      pressureUnit: selectedUnitPressure,
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
            label: 'Inlet Methane Flow',
            controller: _methaneController,
            unitList: flowUnits,
            selectedValue: selectedUnitCH4,
            onChanged: (value) {
              setState(() {
                selectedUnitCH4 = value!;
              });
              _onUnitChanged();
            },
          ),
          _rowWithDropdown(
            label: 'Inlet Carbon Dioxide Flow',
            controller: _co2Controller,
            unitList: flowUnits,
            selectedValue: selectedUnitCO2,
            onChanged: (value) {
              setState(() {
                selectedUnitCO2 = value!;
              });
              _onUnitChanged();
            },
          ),
          _rowWithDropdown(
            label: 'Inlet Water Vapor Flow',
            controller: _h2oController,
            unitList: flowUnits,
            selectedValue: selectedUnitH2O,
            onChanged: (value) {
              setState(() {
                selectedUnitH2O = value!;
              });
              _onUnitChanged();
            },
          ),
          _rowWithDropdown(
            label: 'Pressure',
            controller: _pressureController,
            unitList: const ['bar'],
            selectedValue: selectedUnitPressure,
            onChanged: (value) {
              setState(() {
                selectedUnitPressure = value!;
              });
              _onUnitChanged();
            },
          ),
          const SizedBox(height: 32),
          const Text(
            '* Flows of methane, carbon dioxide and water vapor at inlet temperature and pressure',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _rowWithDropdown({
    required String label,
    required TextEditingController controller,
    required List<String> unitList,
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
            width: 120,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: const InputDecoration(),
              items: unitList
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
