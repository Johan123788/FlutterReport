import 'package:flutter/material.dart';

class UserTheme {
  static const Color bgPrimary     = Color(0xFF0D1117);
  static const Color bgCard        = Color(0xFF161B22);
  static const Color bgSurface     = Color(0xFF21262D);
  static const Color accent        = Color(0xFF3B82F6);
  static const Color accentLight   = Color(0xFF60A5FA);
  static const Color success       = Color(0xFF22C55E);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color danger        = Color(0xFFEF4444);
  static const Color textPrimary   = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color border        = Color(0xFF30363D);

  static Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aceptado':    return success;
      case 'rechazado':   return danger;
      case 'solucionado': return accent;
      default:            return warning;
    }
  }

  static IconData iconEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aceptado':    return Icons.check_circle_rounded;
      case 'rechazado':   return Icons.cancel_rounded;
      case 'solucionado': return Icons.verified_rounded;
      default:            return Icons.pending_rounded;
    }
  }
}