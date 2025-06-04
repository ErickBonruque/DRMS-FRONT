import 'package:flutter/material.dart';

class ResultsTab extends StatefulWidget {
  final Map<String, dynamic>? simulationResults;
  final bool isLoading;

  const ResultsTab({
    super.key, 
    this.simulationResults,
    this.isLoading = false,
  });

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  // Selected array to display
  String _selectedArray = 'CA_history';
  // Selected iteration to display
  int _selectedIteration = 0;

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
        child: Center(
          child: Text(
            'No simulation results available. Click Run to start a simulation.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
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
        child: Center(
          child: Text(
            'Data structure error: $_selectedArray not found in results',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
            ),
          ),
        ),
      );
    }

    // Get the number of iterations
    final iterations = widget.simulationResults![_selectedArray]?.length ?? 0;
    print('Number of iterations for $_selectedArray: $iterations');
    
    // Get the current array data
    final arrayData = widget.simulationResults![_selectedArray];
    
    // Check array data type
    print('arrayData type: ${arrayData.runtimeType}');
    if (arrayData is! List) {
      return Center(child: Text('Error: $_selectedArray is not a List'));
    }
    
    // Get the current iteration data if available
    final iterationData = _selectedIteration < iterations 
      ? arrayData[_selectedIteration] 
      : null;
      
    if (iterationData != null) {
      print('iterationData type: ${iterationData.runtimeType}');
      if (iterationData is! List) {
        return Center(child: Text('Error: iteration data is not a List'));
      }
      print('iterationData length: ${iterationData.length}');
      if (iterationData.isNotEmpty) {
        print('First row type: ${iterationData[0].runtimeType}');
        if (iterationData[0] is List) {
          print('First row length: ${iterationData[0].length}');
        }
      }
    } else {
      print('iterationData is null');
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Array selector
          Row(
            children: [
              Text('Select Array:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedArray,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedArray = newValue;
                      _selectedIteration = 0; // Reset iteration when array changes
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
            ],
          ),
          const SizedBox(height: 16),
          
          // Iteration selector
          Row(
            children: [
              Text('Iteration:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _selectedIteration.toDouble(),
                  min: 0,
                  max: (iterations - 1).toDouble(),
                  divisions: iterations > 1 ? iterations - 1 : 1,
                  label: _selectedIteration.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _selectedIteration = value.toInt();
                    });
                  },
                ),
              ),
              Text(_selectedIteration.toString()),
            ],
          ),
          const SizedBox(height: 24),
          
          // Display the array data
          Expanded(
            child: iterationData != null 
              ? _buildArrayDataDisplay(iterationData)
              : Center(child: Text('No data available for this iteration')),
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
                '$_selectedArray - Iteration $_selectedIteration',
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
