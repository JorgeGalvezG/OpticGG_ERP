import 'package:flutter/material.dart';

class AppColors {
  // Paleta Centro Óptico Cubas 20/20: Cian Clínico Vivo y Azul Medianoche
  // Un balance entre energía (modernidad) y sobriedad (medicina)
  
  static const Color primary = Color(0xFF0077B6); // Azul Océano Vibrante
  static const Color primaryLight = Color(0xFFADE8F4); // Cian Suave
  static const Color secondary = Color(0xFF00B4D8); // Turquesa Médico

  // Tonos de estado
  static const Color success = Color(0xFF06D6A0); // Verde Menta Vivo
  static const Color warning = Color(0xFFFFD166); // Amarillo Sol
  static const Color danger = Color(0xFFEF476F);  // Rosa/Rojo Vibrante

  // Escala de Grises - Neutros Limpios
  static const Color background = Color(0xFFF1F5F9); 
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

  // Gradiente para fondos (Vibrante pero elegante)
  static const LinearGradient loginGradient = LinearGradient(
    colors: [
      Color(0xFF03045E), // Azul Medianoche
      Color(0xFF0077B6), // Azul Océano
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF0077B6),
      Color(0xFF00B4D8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- PALETA ASTRONÓMICA (Nebulosa & Espacio Profundo) ---
  static const Color cosmicDeep = Color(0xFF0B0D17); // Negro Espacial
  static const Color nebulaPurple = Color(0xFF6B4EE6); // Púrpura Nebulosa
  static const Color nebulaPink = Color(0xFFE94560); // Rosa Estelar
  static const Color starlight = Color(0xFFE0E1DD); // Luz de Estrella

  static const LinearGradient nebulaGradient = LinearGradient(
    colors: [
      Color(0xFF0F3460), // Azul Galaxia
      Color(0xFF533483), // Violeta Cósmico
      Color(0xFFE94560), // Rosa Estelar
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spaceGradient = LinearGradient(
    colors: [
      Color(0xFF0B0D17),
      Color(0xFF1B262C),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}