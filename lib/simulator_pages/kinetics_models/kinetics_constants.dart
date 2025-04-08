import 'package:flutter/material.dart';

class KineticsConstants {
  static const BoxDecoration equationBoxDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    boxShadow: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 3,
        spreadRadius: 1,
        offset: Offset(0, 1),
      ),
    ],
  );
  
  static const List<String> rateUnits = ['mol/kgₐₜₐₗ·h'];
}
