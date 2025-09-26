import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/simulator_configuration.dart';

/// Serviço responsável por gerenciar as configurações do simulador
/// Salva e carrega configurações usando SharedPreferences
class ConfigurationService {
  static const String _configurationsKey = 'simulator_configurations';
  static const String _lastUsedConfigKey = 'last_used_configuration';

  /// Salva uma nova configuração
  Future<bool> saveConfiguration(SimulatorConfiguration config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obter configurações existentes
      final existingConfigs = await getAllConfigurations();
      
      // Verificar se já existe uma configuração com o mesmo nome
      final existingIndex = existingConfigs.indexWhere(
        (c) => c.name.toLowerCase() == config.name.toLowerCase()
      );
      
      if (existingIndex != -1) {
        // Substituir configuração existente
        existingConfigs[existingIndex] = config;
      } else {
        // Adicionar nova configuração
        existingConfigs.add(config);
      }
      
      // Converter para JSON e salvar
      final configurationsJson = existingConfigs.map((c) => c.toJson()).toList();
      final jsonString = json.encode(configurationsJson);
      
      await prefs.setString(_configurationsKey, jsonString);
      
      print('Configuration saved successfully: ${config.name}');
      return true;
    } catch (e) {
      print('Error saving configuration: $e');
      return false;
    }
  }

  /// Carrega todas as configurações salvas
  Future<List<SimulatorConfiguration>> getAllConfigurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_configurationsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> configurationsJson = json.decode(jsonString);
      
      return configurationsJson
          .map((configJson) => SimulatorConfiguration.fromJson(configJson))
          .toList();
    } catch (e) {
      print('Error loading configurations: $e');
      return [];
    }
  }

  /// Carrega uma configuração específica por ID
  Future<SimulatorConfiguration?> getConfigurationById(String id) async {
    try {
      final configurations = await getAllConfigurations();
      
      for (final config in configurations) {
        if (config.id == id) {
          return config;
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading configuration by ID: $e');
      return null;
    }
  }

  /// Exclui uma configuração
  Future<bool> deleteConfiguration(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configurations = await getAllConfigurations();
      
      // Remover configuração com o ID especificado
      configurations.removeWhere((config) => config.id == id);
      
      // Salvar lista atualizada
      final configurationsJson = configurations.map((c) => c.toJson()).toList();
      final jsonString = json.encode(configurationsJson);
      
      await prefs.setString(_configurationsKey, jsonString);
      
      print('Configuration deleted successfully: $id');
      return true;
    } catch (e) {
      print('Error deleting configuration: $e');
      return false;
    }
  }

  /// Salva a última configuração usada
  Future<void> setLastUsedConfiguration(String configId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUsedConfigKey, configId);
    } catch (e) {
      print('Error saving last used configuration: $e');
    }
  }

  /// Obtém a última configuração usada
  Future<SimulatorConfiguration?> getLastUsedConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUsedId = prefs.getString(_lastUsedConfigKey);
      
      if (lastUsedId != null && lastUsedId.isNotEmpty) {
        return await getConfigurationById(lastUsedId);
      }
      
      return null;
    } catch (e) {
      print('Error loading last used configuration: $e');
      return null;
    }
  }

  /// Verifica se uma configuração com o nome especificado já existe
  Future<bool> configurationNameExists(String name) async {
    try {
      final configurations = await getAllConfigurations();
      
      return configurations.any(
        (config) => config.name.toLowerCase() == name.toLowerCase()
      );
    } catch (e) {
      print('Error checking configuration name: $e');
      return false;
    }
  }

  /// Gera um ID único para uma nova configuração
  String generateConfigurationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Limpa todas as configurações salvas (útil para debugging)
  Future<bool> clearAllConfigurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configurationsKey);
      await prefs.remove(_lastUsedConfigKey);
      
      print('All configurations cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing configurations: $e');
      return false;
    }
  }

  /// Exporta todas as configurações como JSON string
  Future<String> exportAllConfigurations() async {
    try {
      final configurations = await getAllConfigurations();
      return json.encode(configurations.map((c) => c.toJson()).toList());
    } catch (e) {
      print('Error exporting configurations: $e');
      return '';
    }
  }

  /// Importa configurações de um JSON string
  Future<bool> importConfigurations(String jsonString) async {
    try {
      final List<dynamic> configurationsJson = json.decode(jsonString);
      final configurations = configurationsJson
          .map((configJson) => SimulatorConfiguration.fromJson(configJson))
          .toList();

      // Salvar configurações importadas
      final prefs = await SharedPreferences.getInstance();
      final existingConfigs = await getAllConfigurations();
      
      // Mesclar com configurações existentes (evitar duplicatas por nome)
      for (final newConfig in configurations) {
        final existingIndex = existingConfigs.indexWhere(
          (c) => c.name.toLowerCase() == newConfig.name.toLowerCase()
        );
        
        if (existingIndex != -1) {
          // Substituir se já existe
          existingConfigs[existingIndex] = newConfig;
        } else {
          // Adicionar se não existe
          existingConfigs.add(newConfig);
        }
      }
      
      // Salvar lista final
      final finalJson = existingConfigs.map((c) => c.toJson()).toList();
      await prefs.setString(_configurationsKey, json.encode(finalJson));
      
      print('Configurations imported successfully');
      return true;
    } catch (e) {
      print('Error importing configurations: $e');
      return false;
    }
  }
}
