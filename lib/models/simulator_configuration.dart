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
  final Map<String, String> parameters;
  final Map<String, bool> enabledReactions;

  KineticsConfig({
    Map<String, String>? parameters,
    Map<String, bool>? enabledReactions,
  }) : parameters = parameters ?? {},
       enabledReactions = enabledReactions ?? {};

  Map<String, dynamic> toJson() {
    return {
      'parameters': parameters,
      'enabledReactions': enabledReactions,
    };
  }

  factory KineticsConfig.fromJson(Map<String, dynamic> json) {
    return KineticsConfig(
      parameters: Map<String, String>.from(json['parameters'] ?? {}),
      enabledReactions: Map<String, bool>.from(json['enabledReactions'] ?? {}),
    );
  }
}

/// Configurações da aba Heat
class HeatConfig {
  final Map<String, String> heatParameters;
  final Map<String, bool> heatOptions;

  HeatConfig({
    Map<String, String>? heatParameters,
    Map<String, bool>? heatOptions,
  }) : heatParameters = heatParameters ?? {},
       heatOptions = heatOptions ?? {};

  Map<String, dynamic> toJson() {
    return {
      'heatParameters': heatParameters,
      'heatOptions': heatOptions,
    };
  }

  factory HeatConfig.fromJson(Map<String, dynamic> json) {
    return HeatConfig(
      heatParameters: Map<String, String>.from(json['heatParameters'] ?? {}),
      heatOptions: Map<String, bool>.from(json['heatOptions'] ?? {}),
    );
  }
}

/// Configurações da aba Simulate
class SimulateConfig {
  final Map<String, String> simulationParameters;
  final Map<String, bool> simulationOptions;

  SimulateConfig({
    Map<String, String>? simulationParameters,
    Map<String, bool>? simulationOptions,
  }) : simulationParameters = simulationParameters ?? {},
       simulationOptions = simulationOptions ?? {};

  Map<String, dynamic> toJson() {
    return {
      'simulationParameters': simulationParameters,
      'simulationOptions': simulationOptions,
    };
  }

  factory SimulateConfig.fromJson(Map<String, dynamic> json) {
    return SimulateConfig(
      simulationParameters: Map<String, String>.from(json['simulationParameters'] ?? {}),
      simulationOptions: Map<String, bool>.from(json['simulationOptions'] ?? {}),
    );
  }
}
