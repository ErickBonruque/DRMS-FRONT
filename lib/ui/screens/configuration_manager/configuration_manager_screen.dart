import 'package:flutter/material.dart';
import '../../../models/simulator_configuration.dart';
import '../../../services/configuration_service.dart';

class ConfigurationManagerScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSimulator;
  final Function(SimulatorConfiguration)? onLoadConfiguration;
  
  const ConfigurationManagerScreen({
    super.key,
    this.onNavigateToSimulator,
    this.onLoadConfiguration,
  });

  @override
  State<ConfigurationManagerScreen> createState() => _ConfigurationManagerScreenState();
}

class _ConfigurationManagerScreenState extends State<ConfigurationManagerScreen> {
  final ConfigurationService _configService = ConfigurationService();
  List<SimulatorConfiguration> _configurations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
  }

  Future<void> _loadConfigurations() async {
    setState(() => _isLoading = true);
    
    try {
      final configurations = await _configService.getAllConfigurations();
      setState(() {
        _configurations = configurations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Erro ao carregar configurações: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.settings, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              'Configurações Salvas',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            tooltip: 'Atualizar lista',
            onPressed: _loadConfigurations,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
            onSelected: (value) {
              switch (value) {
                case 'export_all':
                  _exportAllConfigurations();
                  break;
                case 'import':
                  _importConfigurations();
                  break;
                case 'clear_all':
                  _clearAllConfigurations();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export_all',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 8),
                    Text('Exportar Todas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Importar'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpar Todas', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading ? _buildLoadingWidget() : _buildConfigurationsList(),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Carregando configurações...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationsList() {
    if (_configurations.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com estatísticas
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.storage, color: Colors.blue.shade700, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${_configurations.length} configuração${_configurations.length != 1 ? 'ões' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Clique em uma configuração para aplicá-la ao simulador',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Lista de configurações
          Expanded(
            child: ListView.builder(
              itemCount: _configurations.length,
              itemBuilder: (context, index) {
                final config = _configurations[index];
                return _buildConfigurationCard(config, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(SimulatorConfiguration config, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _loadConfiguration(config),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.settings_applications,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Criada em: ${_formatDate(config.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'load':
                          _loadConfiguration(config);
                          break;
                        case 'duplicate':
                          _duplicateConfiguration(config);
                          break;
                        case 'rename':
                          _renameConfiguration(config);
                          break;
                        case 'delete':
                          _deleteConfiguration(config);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'load',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Aplicar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Renomear'),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Informações resumidas da configuração
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo da Configuração:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 6),
                    _buildConfigSummary(config),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              // Botões de ação principais
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _loadConfiguration(config),
                      icon: Icon(Icons.play_arrow, size: 18),
                      label: Text('Aplicar Configuração'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _deleteConfiguration(config),
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigSummary(SimulatorConfiguration config) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildSummaryChip('Inlet', Icons.input, Colors.blue),
        _buildSummaryChip('Reactor', Icons.margin, Colors.purple),
        _buildSummaryChip('Kinetics', Icons.science, Colors.orange),
        _buildSummaryChip('Heat', Icons.thermostat, Colors.red),
        _buildSummaryChip('Simulate', Icons.play_circle, Colors.green),
      ],
    );
  }

  Widget _buildSummaryChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_applications,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Nenhuma Configuração Salva',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Você ainda não salvou nenhuma configuração do simulador.\n'
              'Vá para a aba Results e clique em "Salvar Config" para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onNavigateToSimulator,
              icon: Icon(Icons.arrow_back),
              label: Text('Voltar ao Simulador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} às '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadConfiguration(SimulatorConfiguration config) async {
    // TODO: Implementar carregamento de configuração no simulador
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.green),
            SizedBox(width: 8),
            Text('Aplicar Configuração'),
          ],
        ),
        content: Text(
          'Deseja aplicar a configuração "${config.name}"?\n\n'
          'Isto preencherá automaticamente todos os campos do simulador com os valores salvos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Aplicar'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      // Salvar como última configuração usada
      await _configService.setLastUsedConfiguration(config.id);
      
      // Carregar configuração no simulador
      if (widget.onLoadConfiguration != null) {
        widget.onLoadConfiguration!(config);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Configuração "${config.name}" aplicada com sucesso!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: 80, // Posiciona mais acima da parte inferior
              left: 16,
              right: 16,
            ),
            duration: Duration(seconds: 2), // Reduz duração para ser menos intrusivo
          ),
        );
        
        // Voltar para o simulador
        if (widget.onNavigateToSimulator != null) {
          widget.onNavigateToSimulator!();
        }
      }
    }
  }

  Future<void> _deleteConfiguration(SimulatorConfiguration config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja excluir a configuração "${config.name}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Excluir'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      final success = await _configService.deleteConfiguration(config.id);
      
      if (success) {
        await _loadConfigurations(); // Recarregar lista
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Configuração "${config.name}" excluída com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _showErrorMessage('Erro ao excluir configuração');
      }
    }
  }

  Future<void> _duplicateConfiguration(SimulatorConfiguration config) async {
    // TODO: Implementar duplicação de configuração
    _showInfoMessage('Funcionalidade em desenvolvimento');
  }

  Future<void> _renameConfiguration(SimulatorConfiguration config) async {
    // TODO: Implementar renomeação de configuração
    _showInfoMessage('Funcionalidade em desenvolvimento');
  }

  Future<void> _exportAllConfigurations() async {
    // TODO: Implementar exportação de configurações
    _showInfoMessage('Funcionalidade em desenvolvimento');
  }

  Future<void> _importConfigurations() async {
    // TODO: Implementar importação de configurações
    _showInfoMessage('Funcionalidade em desenvolvimento');
  }

  Future<void> _clearAllConfigurations() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Limpeza'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja excluir TODAS as configurações?\n\n'
          'Esta ação não pode ser desfeita e removerá permanentemente todas as ${_configurations.length} configurações salvas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Excluir Todas'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      final success = await _configService.clearAllConfigurations();
      
      if (success) {
        await _loadConfigurations(); // Recarregar lista
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Todas as configurações foram excluídas!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _showErrorMessage('Erro ao limpar configurações');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showInfoMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
