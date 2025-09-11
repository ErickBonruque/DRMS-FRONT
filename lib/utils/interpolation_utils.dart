/// Utilitários para interpolação linear de dados de simulação
/// 
/// Este arquivo contém funções para realizar interpolação linear entre
/// pontos de tempo nos resultados da simulação do reator catalítico.

class InterpolationUtils {
  /// Realiza interpolação linear entre dois pontos
  /// 
  /// Dados:
  /// - t1, v1 = tempo anterior e seu valor
  /// - t2, v2 = próximo tempo e seu valor  
  /// - t = tempo desejado (t1 < t < t2)
  /// 
  /// Fórmula: v = v1 + ( (v2 - v1) * (t - t1) / (t2 - t1) )
  static double linearInterpolation({
    required double t1,
    required double v1,
    required double t2,
    required double v2,
    required double t,
  }) {
    // Verificar se o tempo está dentro do intervalo válido
    if (t < t1 || t > t2) {
      throw ArgumentError('Tempo desejado ($t) deve estar entre t1 ($t1) e t2 ($t2)');
    }
    
    // Verificar se t1 e t2 são diferentes para evitar divisão por zero
    if (t1 == t2) {
      return v1; // Se os tempos são iguais, retorna o valor
    }
    
    // Aplicar fórmula de interpolação linear
    final interpolatedValue = v1 + ((v2 - v1) * (t - t1) / (t2 - t1));
    return interpolatedValue;
  }
  
  /// Encontra os dois pontos de tempo mais próximos de um tempo desejado
  /// 
  /// Retorna um Map com:
  /// - 'lowerIndex': índice do tempo inferior
  /// - 'upperIndex': índice do tempo superior
  /// - 'lowerTime': valor do tempo inferior
  /// - 'upperTime': valor do tempo superior
  /// - 'exactMatch': true se encontrou correspondência exata
  static Map<String, dynamic> findSurroundingTimePoints({
    required List<double> times,
    required double targetTime,
  }) {
    if (times.isEmpty) {
      throw ArgumentError('Lista de tempos não pode estar vazia');
    }
    
    // Verificar se há correspondência exata
    for (int i = 0; i < times.length; i++) {
      if (times[i] == targetTime) {
        return {
          'lowerIndex': i,
          'upperIndex': i,
          'lowerTime': times[i],
          'upperTime': times[i],
          'exactMatch': true,
        };
      }
    }
    
    // Encontrar os pontos ao redor do tempo desejado
    int lowerIndex = -1;
    int upperIndex = -1;
    
    for (int i = 0; i < times.length - 1; i++) {
      if (times[i] <= targetTime && times[i + 1] >= targetTime) {
        lowerIndex = i;
        upperIndex = i + 1;
        break;
      }
    }
    
    // Se não encontrou pontos ao redor, verificar extremos
    if (lowerIndex == -1) {
      if (targetTime < times.first) {
        // Tempo menor que o mínimo - usar os dois primeiros pontos
        lowerIndex = 0;
        upperIndex = times.length > 1 ? 1 : 0;
      } else if (targetTime > times.last) {
        // Tempo maior que o máximo - usar os dois últimos pontos
        lowerIndex = times.length > 1 ? times.length - 2 : 0;
        upperIndex = times.length - 1;
      }
    }
    
    return {
      'lowerIndex': lowerIndex,
      'upperIndex': upperIndex,
      'lowerTime': times[lowerIndex],
      'upperTime': times[upperIndex],
      'exactMatch': false,
    };
  }
  
  /// Interpola todos os valores de uma linha de dados para um tempo específico
  /// 
  /// Esta função aplica interpolação para todas as variáveis (CA, CB, CC, CD, CE, CF, T)
  /// retornadas pelo backend entre dois pontos de tempo.
  static List<double> interpolateDataRow({
    required List<double> lowerRow,
    required List<double> upperRow,
    required double t1,
    required double t2,
    required double targetTime,
  }) {
    if (lowerRow.length != upperRow.length) {
      throw ArgumentError('As linhas de dados devem ter o mesmo tamanho');
    }
    
    List<double> interpolatedRow = [];
    
    // Interpolar cada valor na linha
    for (int i = 0; i < lowerRow.length; i++) {
      final interpolatedValue = linearInterpolation(
        t1: t1,
        v1: lowerRow[i],
        t2: t2,
        v2: upperRow[i],
        t: targetTime,
      );
      interpolatedRow.add(interpolatedValue);
    }
    
    return interpolatedRow;
  }
  
  /// Interpola dados completos de simulação para um tempo específico
  /// 
  /// Retorna os dados interpolados no mesmo formato que os resultados originais
  static Map<String, dynamic> interpolateSimulationData({
    required Map<String, dynamic> simulationResults,
    required double targetTime,
  }) {
    // Variáveis a serem interpoladas
    final variables = ['CA_history', 'CB_history', 'CC_history', 'CD_history', 
                      'CE_history', 'CF_history', 'T_history'];
    
    Map<String, dynamic> interpolatedResults = {};
    
    // Assumir que os tempos estão disponíveis como uma lista
    // (isso pode precisar ser ajustado baseado na estrutura real dos dados)
    List<double> times = [];
    
    // Extrair tempos da simulação (assumindo que estão em algum lugar dos resultados)
    // Esta parte pode precisar ser ajustada baseada na estrutura real dos dados
    if (simulationResults.containsKey('times')) {
      times = List<double>.from(simulationResults['times']);
    } else {
      // Se não houver tempos explícitos, criar baseado no número de iterações
      final firstVariable = simulationResults[variables.first];
      if (firstVariable is List && firstVariable.isNotEmpty) {
        final numIterations = firstVariable.length;
        times = List.generate(numIterations, (index) => index.toDouble());
      }
    }
    
    if (times.isEmpty) {
      throw StateError('Não foi possível determinar os tempos da simulação');
    }
    
    // Encontrar pontos de tempo ao redor do tempo desejado
    final surroundingPoints = findSurroundingTimePoints(
      times: times,
      targetTime: targetTime,
    );
    
    // Se houver correspondência exata, retornar os dados originais
    if (surroundingPoints['exactMatch']) {
      final exactIndex = surroundingPoints['lowerIndex'];
      for (String variable in variables) {
        if (simulationResults.containsKey(variable)) {
          final variableData = simulationResults[variable];
          if (variableData is List && exactIndex < variableData.length) {
            interpolatedResults[variable] = [variableData[exactIndex]];
          }
        }
      }
      return interpolatedResults;
    }
    
    // Realizar interpolação para cada variável
    final lowerIndex = surroundingPoints['lowerIndex'];
    final upperIndex = surroundingPoints['upperIndex'];
    final lowerTime = surroundingPoints['lowerTime'];
    final upperTime = surroundingPoints['upperTime'];
    
    for (String variable in variables) {
      if (simulationResults.containsKey(variable)) {
        final variableData = simulationResults[variable];
        if (variableData is List && 
            lowerIndex < variableData.length && 
            upperIndex < variableData.length) {
          
          final lowerData = variableData[lowerIndex];
          final upperData = variableData[upperIndex];
          
          if (lowerData is List && upperData is List) {
            // Interpolar cada linha da matriz
            List<List<double>> interpolatedMatrix = [];
            
            for (int rowIndex = 0; rowIndex < lowerData.length && rowIndex < upperData.length; rowIndex++) {
              final lowerRow = List<double>.from(lowerData[rowIndex]);
              final upperRow = List<double>.from(upperData[rowIndex]);
              
              final interpolatedRow = interpolateDataRow(
                lowerRow: lowerRow,
                upperRow: upperRow,
                t1: lowerTime,
                t2: upperTime,
                targetTime: targetTime,
              );
              
              interpolatedMatrix.add(interpolatedRow);
            }
            
            interpolatedResults[variable] = [interpolatedMatrix];
          }
        }
      }
    }
    
    return interpolatedResults;
  }
}
