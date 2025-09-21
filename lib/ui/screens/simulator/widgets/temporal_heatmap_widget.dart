import 'package:flutter/material.dart';
import 'dart:math' as math;

class TemporalHeatmapWidget extends StatefulWidget {
  final List<List<List<double>>> timeSeriesData; // [tempo][linha][coluna]
  final String title;
  final String arrayName;
  
  const TemporalHeatmapWidget({
    super.key,
    required this.timeSeriesData,
    required this.title,
    required this.arrayName,
  });

  @override
  State<TemporalHeatmapWidget> createState() => _TemporalHeatmapWidgetState();
}

class _TemporalHeatmapWidgetState extends State<TemporalHeatmapWidget> {
  int? selectedTime;
  int? selectedRow;
  int? selectedCol;
  
  @override
  Widget build(BuildContext context) {
    if (widget.timeSeriesData.isEmpty || 
        widget.timeSeriesData[0].isEmpty || 
        widget.timeSeriesData[0][0].isEmpty) {
      return Center(
        child: Text('Dados insuficientes para gerar o gráfico temporal'),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800, // Limita o tamanho máximo
          maxHeight: 600,
        ),
        child: Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cabeçalho do gráfico
                _buildHeader(),
                const SizedBox(height: 20),
                
                // Gráfico principal com eixos
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Eixo Y (rótulo vertical)
                      _buildYAxisLabel(),
                      const SizedBox(width: 12),
                      
                      // Coluna do gráfico
                      Flexible(
                        flex: 4,
                        child: Column(
                          children: [
                            // Heatmap temporal
                            Expanded(child: _buildTemporalHeatmap()),
                            const SizedBox(height: 8),
                            // Eixo X (rótulo horizontal)
                            _buildXAxisLabel(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      // Colorbar
                      _buildColorBar(),
                    ],
                  ),
                ),
                
                // Informações adicionais
                if (selectedTime != null && selectedRow != null && selectedCol != null)
                  _buildSelectedValueInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dimensions = widget.timeSeriesData.isNotEmpty && widget.timeSeriesData[0].isNotEmpty 
        ? '${widget.timeSeriesData[0].length}×${widget.timeSeriesData[0][0].length}'
        : 'N/A';
        
    return Column(
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Evolução Temporal Completa (${widget.timeSeriesData.length} tempos)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Grade Espacial: $dimensions | Array: ${widget.arrayName}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildXAxisLabel() {
    return Container(
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                't = 0',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Tempo (iterações)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                't = ${widget.timeSeriesData.length - 1}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.green.shade300],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabel() {
    final rows = widget.timeSeriesData.isNotEmpty && widget.timeSeriesData[0].isNotEmpty 
        ? widget.timeSeriesData[0].length 
        : 0;
    final cols = widget.timeSeriesData.isNotEmpty && 
                 widget.timeSeriesData[0].isNotEmpty && 
                 widget.timeSeriesData[0][0].isNotEmpty
        ? widget.timeSeriesData[0][0].length 
        : 0;
        
    return Container(
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Posição Espacial',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 2,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade300, Colors.orange.shade300],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Text(
                '(0,0)',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '↓',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '($rows×$cols)',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemporalHeatmap() {
    final minValue = _getMinValue();
    final maxValue = _getMaxValue();
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2.0, // Proporção 2:1 para melhor visualização temporal
          child: CustomPaint(
            painter: TemporalHeatmapPainter(
              timeSeriesData: widget.timeSeriesData,
              minValue: minValue,
              maxValue: maxValue,
              selectedTime: selectedTime,
              selectedRow: selectedRow,
              selectedCol: selectedCol,
            ),
            child: GestureDetector(
              onTapDown: (details) {
                _onTap(details.localPosition);
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorBar() {
    final minValue = _getMinValue();
    final maxValue = _getMaxValue();
    final range = maxValue - minValue;
    
    // Determinar unidade baseada no array
    String unit = _getUnit(widget.arrayName);
    String label = _getColorBarLabel(widget.arrayName);
    
    return Container(
      width: 80,
      child: Column(
        children: [
          // Título da escala
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          
          // Barra de cor
          Expanded(
            child: Container(
              width: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _getColorGradient().reversed.toList(),
                ),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Valores min/max com melhor formatação
          Column(
            children: [
              _buildValueLabel(maxValue, 'MAX', Colors.red.shade600),
              const SizedBox(height: 8),
              _buildValueLabel((maxValue + minValue) / 2, 'MED', Colors.orange.shade600),
              const SizedBox(height: 8),
              _buildValueLabel(minValue, 'MIN', Colors.blue.shade600),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Informação sobre o range
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Δ = ${range.toStringAsFixed(3)}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueLabel(double value, String label, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          value.toStringAsFixed(3),
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getUnit(String arrayName) {
    switch (arrayName) {
      case 'T_history':
        return '(K)';
      case 'CA_history':
      case 'CB_history':
      case 'CC_history':
      case 'CD_history':
      case 'CE_history':
      case 'CF_history':
        return '(mol/m³)';
      default:
        return '';
    }
  }

  String _getColorBarLabel(String arrayName) {
    switch (arrayName) {
      case 'T_history':
        return 'Temperatura';
      default:
        return 'Concentração';
    }
  }

  Widget _buildSelectedValueInfo() {
    final value = widget.timeSeriesData[selectedTime!][selectedRow!][selectedCol!];
    final unit = _getUnit(widget.arrayName);
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.touch_app, 
              color: Colors.white, 
              size: 18
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ponto Selecionado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildInfoChip('Tempo', '$selectedTime', Colors.green),
                  const SizedBox(width: 8),
                  _buildInfoChip('Posição', '($selectedCol, $selectedRow)', Colors.purple),
                  const SizedBox(width: 8),
                  _buildInfoChip('Valor', '${value.toStringAsFixed(4)} $unit', Colors.orange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    // Criar tons mais escuros da cor usando Color.lerp
    final Color darkColor = Color.lerp(color, Colors.black, 0.3) ?? color;
    final Color darkerColor = Color.lerp(color, Colors.black, 0.5) ?? color;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: darkerColor,
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(Offset localPosition) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final size = box.size;
    final timeSteps = widget.timeSeriesData.length;
    final rows = widget.timeSeriesData[0].length;
    final cols = widget.timeSeriesData[0][0].length;
    
    // Calcular dimensões do heatmap (considerando aspect ratio 2:1)
    final heatmapWidth = size.width - 80; // desconta colorbar e padding
    final heatmapHeight = size.height;
    
    // No gráfico temporal, X = tempo, Y = posição espacial combinada
    final cellWidth = heatmapWidth / timeSteps;
    final cellHeight = heatmapHeight / (rows * cols);
    
    final timeIndex = (localPosition.dx / cellWidth).floor();
    final spatialIndex = (localPosition.dy / cellHeight).floor();
    
    if (timeIndex >= 0 && timeIndex < timeSteps && 
        spatialIndex >= 0 && spatialIndex < (rows * cols)) {
      
      final row = spatialIndex ~/ cols;
      final col = spatialIndex % cols;
      
      setState(() {
        selectedTime = timeIndex;
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  double _getMinValue() {
    double min = widget.timeSeriesData[0][0][0];
    for (final timeData in widget.timeSeriesData) {
      for (final row in timeData) {
        for (final value in row) {
          if (value < min) min = value;
        }
      }
    }
    return min;
  }

  double _getMaxValue() {
    double max = widget.timeSeriesData[0][0][0];
    for (final timeData in widget.timeSeriesData) {
      for (final row in timeData) {
        for (final value in row) {
          if (value > max) max = value;
        }
      }
    }
    return max;
  }

  List<Color> _getColorGradient() {
    return [
      Color(0xFF0D47A1), // Azul escuro
      Color(0xFF1976D2), // Azul
      Color(0xFF42A5F5), // Azul claro
      Color(0xFF81C784), // Verde claro
      Color(0xFFFFEB3B), // Amarelo
      Color(0xFFFF9800), // Laranja
      Color(0xFFE53935), // Vermelho
    ];
  }
}

class TemporalHeatmapPainter extends CustomPainter {
  final List<List<List<double>>> timeSeriesData;
  final double minValue;
  final double maxValue;
  final int? selectedTime;
  final int? selectedRow;
  final int? selectedCol;

  TemporalHeatmapPainter({
    required this.timeSeriesData,
    required this.minValue,
    required this.maxValue,
    this.selectedTime,
    this.selectedRow,
    this.selectedCol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (timeSeriesData.isEmpty || timeSeriesData[0].isEmpty || timeSeriesData[0][0].isEmpty) return;

    final timeSteps = timeSeriesData.length;
    final rows = timeSeriesData[0].length;
    final cols = timeSeriesData[0][0].length;
    
    final cellWidth = size.width / timeSteps;
    final cellHeight = size.height / (rows * cols);

    final colorGradient = _getColorGradient();
    
    // Desenhar o heatmap temporal
    for (int t = 0; t < timeSteps; t++) {
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
          final value = timeSeriesData[t][row][col];
          final normalizedValue = (value - minValue) / (maxValue - minValue);
          
          // Determinar cor baseada no valor normalizado
          final color = _interpolateColor(colorGradient, normalizedValue);
          
          // Posição espacial combinada (row * cols + col)
          final spatialIndex = row * cols + col;
          
          // Desenhar célula
          final rect = Rect.fromLTWH(
            t * cellWidth,
            spatialIndex * cellHeight,
            cellWidth,
            cellHeight,
          );
          
          final paint = Paint()..color = color;
          canvas.drawRect(rect, paint);
          
          // Destacar célula selecionada
          if (selectedTime == t && selectedRow == row && selectedCol == col) {
            final borderPaint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            canvas.drawRect(rect, borderPaint);
            
            final outerBorderPaint = Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1;
            canvas.drawRect(rect, outerBorderPaint);
          }
        }
      }
    }
    
    // Desenhar linhas de grade para separar tempos
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;
    
    for (int t = 1; t < timeSteps; t++) {
      final x = t * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  Color _interpolateColor(List<Color> gradient, double value) {
    value = value.clamp(0.0, 1.0);
    
    if (gradient.isEmpty) return Colors.grey;
    if (gradient.length == 1) return gradient[0];
    
    final segmentSize = 1.0 / (gradient.length - 1);
    final segmentIndex = (value / segmentSize).floor();
    final segmentValue = (value % segmentSize) / segmentSize;
    
    if (segmentIndex >= gradient.length - 1) {
      return gradient.last;
    }
    
    final color1 = gradient[segmentIndex];
    final color2 = gradient[segmentIndex + 1];
    
    return Color.lerp(color1, color2, segmentValue) ?? color1;
  }

  List<Color> _getColorGradient() {
    return [
      Color(0xFF0D47A1), // Azul escuro
      Color(0xFF1976D2), // Azul
      Color(0xFF42A5F5), // Azul claro
      Color(0xFF81C784), // Verde claro
      Color(0xFFFFEB3B), // Amarelo
      Color(0xFFFF9800), // Laranja
      Color(0xFFE53935), // Vermelho
    ];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
