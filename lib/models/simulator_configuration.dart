import 'dart:convert';

/// Modelo que representa uma configuração completa do simulador
class SimulatorConfiguration {
  final String id;
  final String name;
  final DateTime createdAt;
  final InletFlowsConfig inletFlows;
  final ReactorConfig reactor;
  final KineticsConfig kinetics;
  final HeatConfig heat;
  final SimulateConfig simulate;

  SimulatorConfiguration({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.inletFlows,
    required this.reactor,
    required this.kinetics,
    required this.heat,
    required this.simulate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'inletFlows': inletFlows.toJson(),
      'reactor': reactor.toJson(),
      'kinetics': kinetics.toJson(),
      'heat': heat.toJson(),
      'simulate': simulate.toJson(),
    };
  }

  factory SimulatorConfiguration.fromJson(Map<String, dynamic> json) {
    return SimulatorConfiguration(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      inletFlows: InletFlowsConfig.fromJson(json['inletFlows'] ?? {}),
      reactor: ReactorConfig.fromJson(json['reactor'] ?? {}),
      kinetics: KineticsConfig.fromJson(json['kinetics'] ?? {}),
      heat: HeatConfig.fromJson(json['heat'] ?? {}),
      simulate: SimulateConfig.fromJson(json['simulate'] ?? {}),
    );
  }

  String toJsonString() => json.encode(toJson());

  static SimulatorConfiguration fromJsonString(String jsonString) {
    return SimulatorConfiguration.fromJson(json.decode(jsonString));
  }
}

/// Configurações da aba Inlet Flows
class InletFlowsConfig {
  final String methanFlow;
  final String methaneFlowUnit;
  final String co2Flow;
  final String co2FlowUnit;
  final String h2oFlow;
  final String h2oFlowUnit;
  final String pressure;
  final String pressureUnit;

  InletFlowsConfig({
    this.methanFlow = '',
    this.methaneFlowUnit = 'm³/s',
    this.co2Flow = '',
    this.co2FlowUnit = 'm³/s',
    this.h2oFlow = '',
    this.h2oFlowUnit = 'm³/s',
    this.pressure = '',
    this.pressureUnit = 'bar',
  });

  Map<String, dynamic> toJson() {
    return {
      'methanFlow': methanFlow,
      'methaneFlowUnit': methaneFlowUnit,
      'co2Flow': co2Flow,
      'co2FlowUnit': co2FlowUnit,
      'h2oFlow': h2oFlow,
      'h2oFlowUnit': h2oFlowUnit,
      'pressure': pressure,
      'pressureUnit': pressureUnit,
    };
  }

  factory InletFlowsConfig.fromJson(Map<String, dynamic> json) {
    return InletFlowsConfig(
      methanFlow: json['methanFlow'] ?? '',
      methaneFlowUnit: json['methaneFlowUnit'] ?? 'm³/s',
      co2Flow: json['co2Flow'] ?? '',
      co2FlowUnit: json['co2FlowUnit'] ?? 'm³/s',
      h2oFlow: json['h2oFlow'] ?? '',
      h2oFlowUnit: json['h2oFlowUnit'] ?? 'm³/s',
      pressure: json['pressure'] ?? '',
      pressureUnit: json['pressureUnit'] ?? 'bar',
    );
  }
}

/// Configurações da aba Reactor
class ReactorConfig {
  final String length;
  final String lengthUnit;
  final String diameter;
  final String diameterUnit;
  final String catalystPorosity;
  final String catalystDensity;
  final String particleDiameter;
  final String particleDiameterUnit;

  ReactorConfig({
    this.length = '',
    this.lengthUnit = 'm',
    this.diameter = '',
    this.diameterUnit = 'm',
    this.catalystPorosity = '',
    this.catalystDensity = '',
    this.particleDiameter = '',
    this.particleDiameterUnit = 'm',
  });

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'lengthUnit': lengthUnit,
      'diameter': diameter,
      'diameterUnit': diameterUnit,
      'catalystPorosity': catalystPorosity,
      'catalystDensity': catalystDensity,
      'particleDiameter': particleDiameter,
      'particleDiameterUnit': particleDiameterUnit,
    };
  }

  factory ReactorConfig.fromJson(Map<String, dynamic> json) {
    return ReactorConfig(
      length: json['length'] ?? '',
      lengthUnit: json['lengthUnit'] ?? 'm',
      diameter: json['diameter'] ?? '',
      diameterUnit: json['diameterUnit'] ?? 'm',
      catalystPorosity: json['catalystPorosity'] ?? '',
      catalystDensity: json['catalystDensity'] ?? '',
      particleDiameter: json['particleDiameter'] ?? '',
      particleDiameterUnit: json['particleDiameterUnit'] ?? 'm',
    );
  }
}

/// Configurações da aba Kinetics
class KineticsConfig {
  // Reações selecionadas
  final Map<String, bool> selectedReactions;
  // Modelos cinéticos para cada reação
  final Map<String, String> selectedKineticsForReaction;
  // Reversibilidade para cada reação
  final Map<String, bool> isReversible;
  // Unidade de taxa selecionada
  final String selectedRateUnit;
  // Parâmetros dos modelos (A_SMR, E_SMR, etc.)
  final Map<String, String> modelParameters;

  KineticsConfig({
    Map<String, bool>? selectedReactions,
    Map<String, String>? selectedKineticsForReaction,
    Map<String, bool>? isReversible,
    this.selectedRateUnit = 'mol/kgₐₜₐₗ·h',
    Map<String, String>? modelParameters,
  }) : selectedReactions = selectedReactions ?? {
         'SMR': false,
         'DRM': true,
         'WGS': false,
       },
       selectedKineticsForReaction = selectedKineticsForReaction ?? {
         'SMR': 'Power-Law',
         'DRM': 'Power-Law',
         'WGS': 'Power-Law',
       },
       isReversible = isReversible ?? {
         'SMR': false,
         'DRM': false,
         'WGS': false,
       },
       modelParameters = modelParameters ?? {};

  Map<String, dynamic> toJson() {
    return {
      'selectedReactions': selectedReactions,
      'selectedKineticsForReaction': selectedKineticsForReaction,
      'isReversible': isReversible,
      'selectedRateUnit': selectedRateUnit,
      'modelParameters': modelParameters,
    };
  }

  factory KineticsConfig.fromJson(Map<String, dynamic> json) {
    return KineticsConfig(
      selectedReactions: Map<String, bool>.from(json['selectedReactions'] ?? {
        'SMR': false,
        'DRM': true,
        'WGS': false,
      }),
      selectedKineticsForReaction: Map<String, String>.from(json['selectedKineticsForReaction'] ?? {
        'SMR': 'Power-Law',
        'DRM': 'Power-Law',
        'WGS': 'Power-Law',
      }),
      isReversible: Map<String, bool>.from(json['isReversible'] ?? {
        'SMR': false,
        'DRM': false,
        'WGS': false,
      }),
      selectedRateUnit: json['selectedRateUnit'] ?? 'mol/kgₐₜₐₗ·h',
      modelParameters: Map<String, String>.from(json['modelParameters'] ?? {}),
    );
  }
}

/// Configurações da aba Heat
class HeatConfig {
  // Valores dos campos
  final String overallHeatTransferCoeff;
  final String inletTemperature;
  final String externalTemperature;
  
  // Unidades selecionadas
  final String selectedInletTempUnit;
  final String selectedExternalTempUnit;

  HeatConfig({
    this.overallHeatTransferCoeff = '',
    this.inletTemperature = '',
    this.externalTemperature = '',
    this.selectedInletTempUnit = 'K',
    this.selectedExternalTempUnit = 'K',
  });

  Map<String, dynamic> toJson() {
    return {
      'overallHeatTransferCoeff': overallHeatTransferCoeff,
      'inletTemperature': inletTemperature,
      'externalTemperature': externalTemperature,
      'selectedInletTempUnit': selectedInletTempUnit,
      'selectedExternalTempUnit': selectedExternalTempUnit,
    };
  }

  factory HeatConfig.fromJson(Map<String, dynamic> json) {
    return HeatConfig(
      overallHeatTransferCoeff: json['overallHeatTransferCoeff'] ?? '',
      inletTemperature: json['inletTemperature'] ?? '',
      externalTemperature: json['externalTemperature'] ?? '',
      selectedInletTempUnit: json['selectedInletTempUnit'] ?? 'K',
      selectedExternalTempUnit: json['selectedExternalTempUnit'] ?? 'K',
    );
  }
}

/// Configurações da aba Simulate
class SimulateConfig {
  // Termos do balanço de massa
  final Map<String, bool> massBalanceTerms;
  // Termos do balanço de energia
  final Map<String, bool> energyBalanceTerms;
  // Parâmetros de simulação adicionais
  final Map<String, String> simulationParameters;

  SimulateConfig({
    Map<String, bool>? massBalanceTerms,
    Map<String, bool>? energyBalanceTerms,
    Map<String, String>? simulationParameters,
  }) : massBalanceTerms = massBalanceTerms ?? {
         'Accumulation Rate': true,
         'Convection': true,
         'Axial Diffusion': true,
         'Reaction': true,
         'Radial Diffusion': false,
       },
       energyBalanceTerms = energyBalanceTerms ?? {
         'Accumulation Rate': true,
         'Convection': true,
         'Axial Diffusion': true,
         'Reaction': true,
         'Radial Diffusion': false,
         'Heat Transfer': true,
       },
       simulationParameters = simulationParameters ?? {};

  Map<String, dynamic> toJson() {
    return {
      'massBalanceTerms': massBalanceTerms,
      'energyBalanceTerms': energyBalanceTerms,
      'simulationParameters': simulationParameters,
    };
  }

  factory SimulateConfig.fromJson(Map<String, dynamic> json) {
    return SimulateConfig(
      massBalanceTerms: Map<String, bool>.from(json['massBalanceTerms'] ?? {
        'Accumulation Rate': true,
        'Convection': true,
        'Axial Diffusion': true,
        'Reaction': true,
        'Radial Diffusion': false,
      }),
      energyBalanceTerms: Map<String, bool>.from(json['energyBalanceTerms'] ?? {
        'Accumulation Rate': true,
        'Convection': true,
        'Axial Diffusion': true,
        'Reaction': true,
        'Radial Diffusion': false,
        'Heat Transfer': true,
      }),
      simulationParameters: Map<String, String>.from(json['simulationParameters'] ?? {}),
    );
  }
}
