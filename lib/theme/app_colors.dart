import 'package:flutter/material.dart';

/// Design tokens supporting both Obsidian Dark and Executive Light enterprise palettes
class AppColors {
  // Deep OLED Obsidian Dark Canvas & Surfaces
  static const Color obsidian = Color(0xFF07080B);
  static const Color voidBg = Color(0xFF0B0D14);
  static const Color surfaceDark = Color(0xFF111420);
  static const Color surfaceElevated = Color(0xFF161A29);
  static const Color surfaceCard = Color(0xFF1A1F31);

  // Executive Light Canvas & Surfaces
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Frosted Glass & Border Accents (Dark Mode)
  static const Color glassWhite = Color(0x0CFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  // Radiant Brand Accents
  static const Color neonCyan = Color(0xFF00D2E0);
  static const Color brandPrimary = Color(0xFF0284C7); // Executive Sky Blue
  static const Color brandSecondary = Color(0xFF0EA5E9);
  static const Color cyberEmerald = Color(0xFF10B981); // Emerald Retail
  static const Color electricViolet = Color(0xFF8A2BE2);
  static const Color ultraViolet = Color(0xFF6E0DD0);
  static const Color champagneGold = Color(0xFFE5C158);
  static const Color deepGold = Color(0xFFB38F2E);
  static const Color liquidRose = Color(0xFFF79489);

  // Dark Monochromatic Text & Icon Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF334155);

  // Light Monochromatic Text & Icon Hierarchy
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // Status Indicators
  static const Color stockGreen = Color(0xFF10B981);
  static const Color alertOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Gradient Presets
  static const LinearGradient iridescentCyanEmerald = LinearGradient(
    colors: [neonCyan, cyberEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient executiveBlueGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
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
