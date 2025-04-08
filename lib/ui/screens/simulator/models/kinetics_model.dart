import 'package:flutter/material.dart';

/// Abstract interface for all kinetics models
abstract class KineticsModel {
  /// Build the rate equation widget
  Widget buildRateEquation();
  
  /// Build the parameter fields widget
  Widget buildParameterFields();
}
