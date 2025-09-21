import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class HeatmapWidget extends StatefulWidget {
  final List<List<double>> data;
  final String title;
  final String? subtitle;
  
  const HeatmapWidget({
    super.key,
    required this.data,
    required this.title,
    this.subtitle,
  });

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  int? selectedX;
  int? selectedY;
  
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty || widget.data[0].isEmpty) {
      return Center(
        child: Text('Dados insuficientes para gerar o gráfico'),
      );
    }

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do gráfico
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Gráfico principal
            Expanded(
              child: Row(
                children: [
                  // Heatmap
                  Expanded(
                    flex: 4,
                    child: _buildHeatmap(),
                  ),
                  const SizedBox(width: 20),
                  // Colorbar
                  _buildColorBar(),
                ],
              ),
            ),
            
            // Informações adicionais
            if (selectedX != null && selectedY != null)
              _buildSelectedValueInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeatmap() {
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
        child: CustomPaint(
          painter: HeatmapPainter(
            data: widget.data,
            minValue: minValue,
            maxValue: maxValue,
            selectedX: selectedX,
            selectedY: selectedY,
          ),
          child: GestureDetector(
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              _onTap(localPosition);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorBar() {
    final minValue = _getMinValue();
    final maxValue = _getMaxValue();
    
    return Container(
      width: 60,
      child: Column(
        children: [
          // Título da escala
          Text(
            'Escala',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          
          // Barra de cor
          Expanded(
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _getColorGradient().reversed.toList(),
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Valores min/max
          Column(
            children: [
              Text(
                maxValue.toStringAsFixed(3),
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                ((maxValue + minValue) / 2).toStringAsFixed(3),
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                minValue.toStringAsFixed(3),
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedValueInfo() {
    final value = widget.data[selectedY!][selectedX!];
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.blue.shade700, size: 16),
          const SizedBox(width: 8),
          Text(
            'Posição: ($selectedX, $selectedY) | Valor: ${value.toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(Offset localPosition) {
    // Calcular posição no heatmap baseada no toque
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final size = box.size;
    final cols = widget.data[0].length;
    final rows = widget.data.length;
    
    // Ajustar para levar em conta padding e colorbar
    final heatmapWidth = size.width - 80; // desconta colorbar e padding
    final heatmapHeight = size.height;
    
    final cellWidth = heatmapWidth / cols;
    final cellHeight = heatmapHeight / rows;
    
    final x = (localPosition.dx / cellWidth).floor();
    final y = (localPosition.dy / cellHeight).floor();
    
    if (x >= 0 && x < cols && y >= 0 && y < rows) {
      setState(() {
        selectedX = x;
        selectedY = y;
      });
    }
  }

  double _getMinValue() {
    double min = widget.data[0][0];
    for (final row in widget.data) {
      for (final value in row) {
        if (value < min) min = value;
      }
    }
    return min;
  }

  double _getMaxValue() {
    double max = widget.data[0][0];
    for (final row in widget.data) {
      for (final value in row) {
        if (value > max) max = value;
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

class HeatmapPainter extends CustomPainter {
  final List<List<double>> data;
  final double minValue;
  final double maxValue;
  final int? selectedX;
  final int? selectedY;

  HeatmapPainter({
    required this.data,
    required this.minValue,
    required this.maxValue,
    this.selectedX,
    this.selectedY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data[0].isEmpty) return;

    final rows = data.length;
    final cols = data[0].length;
    
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    final colorGradient = _getColorGradient();
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final value = data[row][col];
        final normalizedValue = (value - minValue) / (maxValue - minValue);
        
        // Determinar cor baseada no valor normalizado
        final color = _interpolateColor(colorGradient, normalizedValue);
        
        // Desenhar célula
        final rect = Rect.fromLTWH(
          col * cellWidth,
          row * cellHeight,
          cellWidth,
          cellHeight,
        );
        
        final paint = Paint()..color = color;
        canvas.drawRect(rect, paint);
        
        // Destacar célula selecionada
        if (selectedX == col && selectedY == row) {
          final borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;
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
