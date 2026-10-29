import 'package:flutter/material.dart';

/// Design tokens inspired by Ora (Geneva horology luxury) and Artefakt (iridescent cyber-minimalism)
class AppColors {
  // Deep OLED Canvas & Surfaces
  static const Color obsidian = Color(0xFF07080B);
  static const Color voidBg = Color(0xFF0B0D14);
  static const Color surfaceDark = Color(0xFF111420);
  static const Color surfaceElevated = Color(0xFF161A29);
  static const Color surfaceCard = Color(0xFF1A1F31);

  // Frosted Glass & Border Accents
  static const Color glassWhite = Color(0x0CFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  // Radiant Iridescent Accents
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color cyberEmerald = Color(0xFF00F5A0);
  static const Color electricViolet = Color(0xFF8A2BE2);
  static const Color ultraViolet = Color(0xFF6E0DD0);
  static const Color champagneGold = Color(0xFFE5C158);
  static const Color deepGold = Color(0xFFB38F2E);
  static const Color liquidRose = Color(0xFFF79489);

  // Monochromatic Text & Icon Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF334155);

  // Status Indicators
  static const Color stockGreen = Color(0xFF10B981);
  static const Color alertOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  // Gradient Presets
  static const LinearGradient iridescentCyanEmerald = LinearGradient(
    colors: [neonCyan, cyberEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGold = LinearGradient(
    colors: [champagneGold, deepGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cosmicViolet = LinearGradient(
    colors: [ultraViolet, electricViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
