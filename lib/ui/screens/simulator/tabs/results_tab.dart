import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/interpolation_utils.dart';

class ResultsTab extends StatefulWidget {
  final Map<String, dynamic>? simulationResults;
  final bool isLoading;
  final VoidCallback? onRunSimulation;
  final VoidCallback? onExportData;

  const ResultsTab({
    super.key, 
    this.simulationResults,
    this.isLoading = false,
    this.onRunSimulation,
    this.onExportData,
  });

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  // Selected array to display
  String _selectedArray = 'CA_history';
  // Selected time to display (substitui iteration)
  double _selectedTime = 0.0;
  // Controller para o campo de entrada de tempo
  final TextEditingController _timeController = TextEditingController();
  // Dados interpolados ou originais para exibição
  List<dynamic>? _displayData;
  // Informações sobre interpolação para exibir aviso
  Map<String, dynamic>? _interpolationInfo;

  @override
  void initState() {
    super.initState();
    _timeController.text = _selectedTime.toString();
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building ResultsTab with isLoading: ${widget.isLoading}');
    
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    print('simulationResults: ${widget.simulationResults != null ? "not null" : "null"}');
    
    if (widget.simulationResults == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensagem quando não há resultados
            Expanded(
              child: Center(
                child: Text(
                  'No simulation results available. Click Run to start a simulation.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Debug the structure of simulationResults
    print('simulationResults keys: ${widget.simulationResults!.keys.toList()}');
    
    // Check if the expected arrays exist
    if (!widget.simulationResults!.containsKey(_selectedArray)) {
      print('Warning: $_selectedArray not found in simulationResults');
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensagem de erro
            Expanded(
              child: Center(
                child: Text(
                  'Data structure error: $_selectedArray not found in results',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Obter dados para o tempo selecionado (com interpolação se necessário)
    _updateDisplayData();
    
    // Get the number of iterations para determinar o range de tempo válido
    final arrayData = widget.simulationResults![_selectedArray];
    final iterations = arrayData?.length ?? 0;
    print('Number of iterations for $_selectedArray: $iterations');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Array selector e Tempo na mesma linha
          Row(
            children: [
              // Array selector
              Text('Select Array:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedArray,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedArray = newValue;
                      _selectedTime = 0.0; // Reset tempo quando array muda
                      _timeController.text = '0.0';
                      _interpolationInfo = null; // Reset info de interpolação
                    });
                  }
                },
                items: [
                  'CA_history',
                  'CB_history',
                  'CC_history',
                  'CD_history',
                  'CE_history',
                  'CF_history',
                  'T_history',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              
              const SizedBox(width: 32),
              
              // Seletor de tempo compacto
              Text('Tempo (t):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              SizedBox(
                width: 200, 
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ex: 4.3',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.check, size: 18, color: Colors.green),
                      onPressed: _updateTimeFromInput,
                      tooltip: 'Aplicar tempo',
                    ),
                  ),
                  onSubmitted: (value) => _updateTimeFromInput(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Range: 0-${iterations > 0 ? (iterations - 1) : 0}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          
          // Aviso de interpolação (onde estava o campo de tempo)
          if (_interpolationInfo != null) _buildInterpolationWarning(),
          const SizedBox(height: 24),
          
          // Display the array data
          Expanded(
            child: _displayData != null 
              ? _buildArrayDataDisplay(_displayData!)
              : Center(child: Text('Nenhum dado disponível para este tempo')),
          ),
        ],
      ),
    );
  }
  
  /// Atualiza o tempo selecionado baseado na entrada do usuário
  void _updateTimeFromInput() {
    final inputText = _timeController.text.trim();
    if (inputText.isEmpty) return;
    
    final newTime = double.tryParse(inputText);
    if (newTime == null) {
      // Mostrar erro se o valor não for válido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, digite um número válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _selectedTime = newTime;
      _displayData = null; // Reset para forçar recálculo
      _interpolationInfo = null; // Reset info de interpolação
    });
  }
  
  /// Atualiza os dados de exibição com base no tempo selecionado
  /// Aplica interpolação se o tempo não existir exatamente
  void _updateDisplayData() {
    if (widget.simulationResults == null || 
        !widget.simulationResults!.containsKey(_selectedArray)) {
      _displayData = null;
      return;
    }
    
    final arrayData = widget.simulationResults![_selectedArray];
    if (arrayData is! List || arrayData.isEmpty) {
      _displayData = null;
      return;
    }
    
    final iterations = arrayData.length;
    
    // Verificar se o tempo corresponde exatamente a uma iteração existente
    final targetIteration = _selectedTime.round();
    if (_selectedTime == targetIteration.toDouble() && 
        targetIteration >= 0 && 
        targetIteration < iterations) {
      // Tempo corresponde exatamente - usar dados originais
      _displayData = arrayData[targetIteration];
      _interpolationInfo = null; // Não há interpolação
      return;
    }
    
    // Tempo não corresponde exatamente - aplicar interpolação
    try {
      // Criar lista de tempos (assumindo que correspondem aos índices)
      final times = List.generate(iterations, (index) => index.toDouble());
      
      // Encontrar pontos ao redor do tempo desejado
      final surroundingPoints = InterpolationUtils.findSurroundingTimePoints(
        times: times,
        targetTime: _selectedTime,
      );
      
      if (surroundingPoints['exactMatch']) {
        // Correspondência exata encontrada
        final exactIndex = surroundingPoints['lowerIndex'];
        _displayData = arrayData[exactIndex];
        _interpolationInfo = null; // Não há interpolação
        return;
      }
      
      // Realizar interpolação
      final lowerIndex = surroundingPoints['lowerIndex'];
      final upperIndex = surroundingPoints['upperIndex'];
      final lowerTime = surroundingPoints['lowerTime'];
      final upperTime = surroundingPoints['upperTime'];
      
      if (lowerIndex < 0 || upperIndex >= iterations) {
        // Tempo fora do range válido
        _displayData = null;
        return;
      }
      
      final lowerData = arrayData[lowerIndex];
      final upperData = arrayData[upperIndex];
      
      if (lowerData is! List || upperData is! List) {
        _displayData = null;
        return;
      }
      
      // Interpolar cada linha da matriz
      List<List<double>> interpolatedMatrix = [];
      
      final minRows = lowerData.length < upperData.length ? 
          lowerData.length : upperData.length;
      
      for (int rowIndex = 0; rowIndex < minRows; rowIndex++) {
        final lowerRow = lowerData[rowIndex];
        final upperRow = upperData[rowIndex];
        
        if (lowerRow is! List || upperRow is! List) continue;
        
        try {
          final lowerRowDoubles = lowerRow.map((e) => e is num ? e.toDouble() : 0.0).toList();
          final upperRowDoubles = upperRow.map((e) => e is num ? e.toDouble() : 0.0).toList();
          
          final interpolatedRow = InterpolationUtils.interpolateDataRow(
            lowerRow: lowerRowDoubles,
            upperRow: upperRowDoubles,
            t1: lowerTime,
            t2: upperTime,
            targetTime: _selectedTime,
          );
          
          interpolatedMatrix.add(interpolatedRow);
        } catch (e) {
          print('Erro na interpolação da linha $rowIndex: $e');
          // Em caso de erro, usar dados da linha inferior
          final fallbackRow = lowerRow.map((e) => e is num ? e.toDouble() : 0.0).toList();
          interpolatedMatrix.add(fallbackRow);
        }
      }
      
      _displayData = interpolatedMatrix;
      
      // Salvar informações da interpolação para o aviso
      _interpolationInfo = {
        'lowerTime': lowerTime,
        'upperTime': upperTime,
        'targetTime': _selectedTime,
      };
      
    } catch (e) {
      print('Erro na interpolação: $e');
      // Em caso de erro, usar a iteração mais próxima
      final nearestIteration = _selectedTime.round().clamp(0, iterations - 1);
      _displayData = arrayData[nearestIteration];
      _interpolationInfo = null; // Não há interpolação em caso de erro
    }
  }
  
  /// Constrói o aviso estilizado de interpolação
  Widget _buildInterpolationWarning() {
    if (_interpolationInfo == null) return SizedBox.shrink();
    
    final lowerTime = _interpolationInfo!['lowerTime'];
    final upperTime = _interpolationInfo!['upperTime'];
    final targetTime = _interpolationInfo!['targetTime'];
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícone circular amarelo chamativo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          
          SizedBox(width: 12),
          
          // Container principal do aviso
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    Colors.orange.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Título do aviso
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade700,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Interpolação Linear Aplicada',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 6),
                        
                        // Informações dos pontos
                        Text(
                          'Tempo desejado: ${targetTime.toStringAsFixed(2)} (não existe nos dados originais)',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                          ),
                        ),
                        
                        SizedBox(height: 4),
                        
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade300, width: 1),
                              ),
                              child: Text(
                                't₁ = ${lowerTime.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            
                            SizedBox(width: 8),
                            
                            Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            
                            SizedBox(width: 8),
                            
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300, width: 1),
                              ),
                              child: Text(
                                't₂ = ${upperTime.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Indicador visual de interpolação
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: CustomPaint(
                      painter: InterpolationLinePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArrayDataDisplay(List<dynamic> data) {
    // Handle potential errors in the data structure
    try {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_selectedArray - Tempo $_selectedTime',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, rowIndex) {
                    // Safely access row data
                    final row = data[rowIndex];
                    if (row is! List) {
                      return Text('Error: Row $rowIndex is not a List');
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Row $rowIndex:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              row.length,
                              (colIndex) {
                                // Safely handle the cell value
                                final cellValue = row[colIndex];
                                String displayValue;
                                
                                try {
                                  if (cellValue is num) {
                                    displayValue = cellValue.toStringAsFixed(6);
                                  } else {
                                    displayValue = cellValue.toString();
                                  }
                                } catch (e) {
                                  displayValue = 'Error';
                                }
                                
                                return Container(
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    displayValue,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // Fallback display if there's an error
      print('Error displaying array data: $e');
      return Center(
        child: Text(
          'Error displaying data: $e',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

/// CustomPainter para desenhar uma linha de interpolação visual
class InterpolationLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade600
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final pointPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.fill;
    
    // Desenhar linha de interpolação
    final startX = size.width * 0.15;
    final endX = size.width * 0.85;
    final midY = size.height * 0.5;
    
    // Pontos das extremidades
    final point1 = Offset(startX, midY);
    final point2 = Offset(endX, midY);
    
    // Ponto interpolado no meio
    final interpolatedPoint = Offset(size.width * 0.5, midY);
    
    // Desenhar linha
    canvas.drawLine(point1, point2, paint);
    
    // Desenhar pontos das extremidades
    canvas.drawCircle(point1, 2.5, pointPaint);
    canvas.drawCircle(point2, 2.5, pointPaint);
    
    // Desenhar ponto interpolado (destacado)
    final interpolatedPaint = Paint()
      ..color = Colors.orange.shade600
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(interpolatedPoint, 3.0, interpolatedPaint);
    
    // Adicionar contorno branco ao ponto interpolado
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    canvas.drawCircle(interpolatedPoint, 3.0, outlinePaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
