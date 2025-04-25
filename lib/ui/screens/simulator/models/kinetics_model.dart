import 'package:flutter/material.dart';

/// Interface abstrata para os modelos de cinética
/// que define os métodos necessários para construir
abstract class KineticsModel {
  /// Construir a equação de taxa
  Widget buildRateEquation();
  
  /// Contruir os campos de parâmetros
  Widget buildParameterFields();
}
