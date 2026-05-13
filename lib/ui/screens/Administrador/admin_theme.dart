import 'package:flutter/material.dart';

// 
//  OJO CIUDADANO — ADMIN DESIGN SYSTEM
// 

class AdminTheme {
  // ── Colores principales ──
  static const Color bgPrimary    = Color(0xFF0D1117);   // fondo oscuro
  static const Color bgCard       = Color(0xFF161B22);   // tarjeta
  static const Color bgSurface    = Color(0xFF21262D);   // superficie elevada
  static const Color accent       = Color(0xFF3B82F6);   // azul eléctrico
  static const Color accentLight  = Color(0xFF60A5FA);
  static const Color success      = Color(0xFF22C55E);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color danger       = Color(0xFFEF4444);
  static const Color textPrimary  = Color(0xFFF0F6FC);
  static const Color textSecondary= Color(0xFF8B949E);
  static const Color border       = Color(0xFF30363D);

  // ── Gradientes de autoridades ──
  static const LinearGradient gradientAfinia = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientAlcaldia = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientInteraseo = LinearGradient(
    colors: [Color(0xFF78350F), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Gradiente por estado ──
  static Color colorEstado(String estado) {
    switch (estado) {
      case 'Aceptado':    return success;
      case 'Rechazado':   return danger;
      case 'Solucionado': return accent;
      default:            return warning;
    }
  }
  static IconData iconEstado(String estado) {
    switch (estado) {
      case 'Aceptado':    return Icons.check_circle_rounded;
      case 'Rechazado':   return Icons.cancel_rounded;
      case 'Solucionado': return Icons.verified_rounded;
      default:            return Icons.pending_rounded;
    }
  }
}