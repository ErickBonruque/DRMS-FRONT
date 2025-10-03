import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simulator_configuration.dart';

/// Serviço responsável pela comunicação com o backend Flask
class ApiService {
  // URL base do backend - ajuste conforme necessário
  static const String _baseUrl = 'http://127.0.0.1:5000';
  
  /// Executa simulação enviando configuração completa para o backend
  Future<Map<String, dynamic>> runSimulation(SimulatorConfiguration config) async {
    // Mapear dados da configuração para o formato esperado pelo backend
    final requestData = _mapConfigurationToBackendFormat(config);
    
    print('Enviando dados para o backend: ${json.encode(requestData)}');
    
    try {
      final url = Uri.parse('$_baseUrl/simulate');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );
      
      print('Resposta do backend - Status: ${response.statusCode}');
      print('Resposta do backend - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Falha na simulação: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao executar simulação: $e');
      rethrow;
    }
  }
  
  /// Mapeia a configuração do frontend para o formato esperado pelo backend
  Map<String, dynamic> _mapConfigurationToBackendFormat(SimulatorConfiguration config) {
    // Usar valores padrão se os campos estiverem vazios (para simulação de teste)
    final ch4Flow = _parseDoubleWithDefault(config.inletFlows.methanFlow, defaultValue: 0.001);
    final co2Flow = _parseDoubleWithDefault(config.inletFlows.co2Flow, defaultValue: 0.001);
    final h2oFlow = _parseDoubleWithDefault(config.inletFlows.h2oFlow, defaultValue: 0.0);
    
    return {
      // Dados de entrada (Inlet)
      'inlet': {
        'Q_CH4_m3_s': ch4Flow,
        'Q_CO2_m3_s': co2Flow,
        'Q_H2O_m3_s': h2oFlow,
        'pressure_bar': _parseDoubleWithDefault(config.inletFlows.pressure, defaultValue: 1.0),
      },
      
      // Dados do reator (Reactor)
      'reactor': {
        'length_m': _parseDoubleWithDefault(config.reactor.length, defaultValue: 0.03),
        'diameter_m': _parseDoubleWithDefault(config.reactor.diameter, defaultValue: 0.0063),
        'porosity': _parseDoubleWithDefault(config.reactor.catalystPorosity, defaultValue: 0.50),
        'catalyst_density_kg_m3': _parseDoubleWithDefault(config.reactor.catalystDensity, defaultValue: 53.5),
        'particle_diameter_m': _parseDoubleWithDefault(config.reactor.particleDiameter, defaultValue: 3.0e-4),
        'solid_conductivity_W_mK': 2.8, // Valor padrão conforme backend
      },
      
      // Dados térmicos (Heat)
      'heat': {
        'inlet_temperature_K': _parseDoubleWithDefault(config.heat.inletTemperature, defaultValue: 973.15),
        'external_temperature_K': _parseDoubleWithDefault(config.heat.externalTemperature, defaultValue: 973.15),
        'Utc_kJ_m3_s_K': _parseDoubleOrNull(config.heat.overallHeatTransferCoeff),
      },
      
      // Dados cinéticos (Kinetics) - usando parâmetros DRM padrão
      'kinetics': {
        'A_DRM': _getKineticParameter(config.kinetics, 'A_DRM', 1.45e12/3600.0),
        'E_DRM_J_mol': _getKineticParameter(config.kinetics, 'E_DRM_J_mol', 1.49e5),
        'alpha': _getKineticParameter(config.kinetics, 'alpha', 0.524),
        'beta': _getKineticParameter(config.kinetics, 'beta', 0.0),
        'reversible': config.kinetics.isReversible['DRM'] ?? false,
      },
      
      // Parâmetros de simulação
      'simulate': {
        'n_chunks': _parseIntWithDefault(_getSimulationParameter(config.simulate, 'n_chunks'), defaultValue: 5),
        'Nz': _parseIntWithDefault(_getSimulationParameter(config.simulate, 'Nz'), defaultValue: 100),
        'Nr': _parseIntWithDefault(_getSimulationParameter(config.simulate, 'Nr'), defaultValue: 40),
        't_final_s': _parseDoubleWithDefault(_getSimulationParameter(config.simulate, 't_final_s'), defaultValue: 1.0),
        'min_dt': _parseDoubleOrNull(_getSimulationParameter(config.simulate, 'min_dt')),
        'max_dt': _parseDoubleOrNull(_getSimulationParameter(config.simulate, 'max_dt')),
      },
      
      // Termos de balanço (conforme configuração da aba Simulate)
      'terms': {
        'mass_balance': config.simulate.massBalanceTerms,
        'energy_balance': config.simulate.energyBalanceTerms,
      }
    };
  }
  
  /// Converte string para double com valor padrão
  double _parseDoubleWithDefault(String value, {double defaultValue = 0.0}) {
    if (value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
  
  /// Converte string para double ou retorna null se vazio
  double? _parseDoubleOrNull(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }
  
  /// Converte string para int com valor padrão
  int _parseIntWithDefault(String value, {int defaultValue = 0}) {
    if (value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
  
  /// Obtém parâmetro cinético ou retorna valor padrão
  double _getKineticParameter(KineticsConfig kinetics, String paramName, double defaultValue) {
    final value = kinetics.modelParameters[paramName];
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
  
  /// Obtém parâmetro de simulação
  String _getSimulationParameter(SimulateConfig simulate, String paramName) {
    return simulate.simulationParameters[paramName] ?? '';
  }
  
  /// Teste de conectividade com o backend
  Future<bool> testConnection() async {
    try {
      // Tenta primeiro o endpoint de health check simples
      final url = Uri.parse('$_baseUrl/simular');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao testar conexão com o backend: $e');
      return false;
    }
  }
  
  /// Informações sobre como iniciar o backend
  String getBackendStartupInstructions() {
    return '''
Para iniciar o backend, execute os seguintes comandos no terminal:

1. Navegue até a pasta do backend:
   cd "c:\\Users\\bonru\\OneDrive\\Área de Trabalho\\IC\\back-front\\back"

2. Execute o servidor Flask:
   python app.py

O servidor deve iniciar na porta 5000.
Certifique-se de que as dependências Python estão instaladas:
- Flask
- numpy
- flask-cors (opcional, para CORS)
    ''';
  }
}
