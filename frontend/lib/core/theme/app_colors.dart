import 'package:flutter/material.dart';

class AppColors {
  // Azul Zafiro: Más sobrio, elegante y transmite confianza médica/empresarial
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Tonos de estado más naturales y menos "neón/IA"
  static const Color success = Color(0xFF059669); // Verde esmeralda profundo
  static const Color warning = Color(0xFFD97706); // Ámbar cálido
  static const Color danger = Color(0xFFDC2626);  // Rojo carmesí

  // Escala de grises (Neutrales limpios)
  static const Color background = Color(0xFFF8FAFC);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Gradiente Premium: Un "Midnight Blue" muy elegante, sin saltos bruscos de color
  static const LinearGradient loginGradient = LinearGradient(
    colors: [
      Color(0xFF0B1320), // Azul casi negro (Arriba)
      Color(0xFF15253A), // Azul noche sutil (Abajo)
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}