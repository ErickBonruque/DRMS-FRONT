import 'package:flutter/material.dart';
import '../../../../models/simulator_configuration.dart';

class HeatTab extends StatefulWidget {
  final HeatConfig? initialConfig;
  final Function(HeatConfig)? onConfigChanged;
  
  const HeatTab({
    super.key,
    this.initialConfig,
    this.onConfigChanged,
  });

  @override
  State<HeatTab> createState() => _HeatTabState();
}

class _HeatTabState extends State<HeatTab> {
  final List<String> temperatureUnits = ['K', '°C', '°F'];
  
  // Controllers para os campos de texto
  late TextEditingController _heatTransferController;
  late TextEditingController _inletTempController;
  late TextEditingController _externalTempController;
  
  String selectedInletTempUnit = 'K';
  String selectedExternalTempUnit = 'K';

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers
    _heatTransferController = TextEditingController();
    _inletTempController = TextEditingController();
    _externalTempController = TextEditingController();
    
    // Carregar configuração inicial se fornecida
    if (widget.initialConfig != null) {
      _loadConfiguration(widget.initialConfig!);
    }
    
    // Adicionar listeners para notificar mudanças
    _heatTransferController.addListener(_notifyConfigChanged);
    _inletTempController.addListener(_notifyConfigChanged);
    _externalTempController.addListener(_notifyConfigChanged);
  }

  @override
  void dispose() {
    _heatTransferController.dispose();
    _inletTempController.dispose();
    _externalTempController.dispose();
    super.dispose();
  }

  void _loadConfiguration(HeatConfig config) {
    setState(() {
      _heatTransferController.text = config.overallHeatTransferCoeff;
      _inletTempController.text = config.inletTemperature;
      _externalTempController.text = config.externalTemperature;
      selectedInletTempUnit = config.selectedInletTempUnit;
      selectedExternalTempUnit = config.selectedExternalTempUnit;
    });
  }

  void _notifyConfigChanged() {
    if (widget.onConfigChanged != null) {
      final config = _getCurrentConfiguration();
      widget.onConfigChanged!(config);
    }
  }

  HeatConfig _getCurrentConfiguration() {
    return HeatConfig(
      overallHeatTransferCoeff: _heatTransferController.text,
      inletTemperature: _inletTempController.text,
      externalTemperature: _externalTempController.text,
      selectedInletTempUnit: selectedInletTempUnit,
      selectedExternalTempUnit: selectedExternalTempUnit,
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
        children: [
          _fixedUnitRow('Overall Heat Transfer Coefficient (Utc)', 'kJ/m³sK', _heatTransferController),
          _rowWithUnitOptions(
            label: 'Inlet Temperature',
            controller: _inletTempController,
            unitList: temperatureUnits,
            selectedValue: selectedInletTempUnit,
            onChanged: (value) {
              setState(() {
                selectedInletTempUnit = value!;
              });
              _onUnitChanged();
            },
          ),
          _rowWithUnitOptions(
            label: 'External Temperature',
            controller: _externalTempController,
            unitList: temperatureUnits,
            selectedValue: selectedExternalTempUnit,
            onChanged: (value) {
              setState(() {
                selectedExternalTempUnit = value!;
              });
              _onUnitChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _fixedUnitRow(String label, String unit, TextEditingController controller) {
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
            child: DropdownButtonFormField(
              value: unit,
              items: [DropdownMenuItem(value: unit, child: Text(unit))],
              onChanged: (_) {},
              decoration: const InputDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWithUnitOptions({
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
            width: 100,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              items: unitList
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
}
