import 'package:flutter/material.dart';

/// Abstract base class for all kinetics models
abstract class KineticsModel extends StatelessWidget {
  const KineticsModel({super.key});
  
  /// Build the rate equation widget
  Widget buildRateEquation();
  
  /// Build the parameter fields widget
  Widget buildParameterFields();
}
