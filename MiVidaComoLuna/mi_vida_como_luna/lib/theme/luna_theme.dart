import 'package:flutter/material.dart';

abstract class LunaTheme {
  // ── Backgrounds ──────────────────────────────────────────────────────────────
  static const void_   = Color(0xFF0a0a0f); // --void (main bg)
  static const bg2     = Color(0xFF0d0d14);
  static const bg3     = Color(0xFF111118);
  static const surface = Color(0xFF14141c); // card bg

  // ── Accents ──────────────────────────────────────────────────────────────────
  static const silver  = Color(0xFFc0c0c0); // --luna-silver
  static const purple  = Color(0xFF667eea); // --luna-purple
  static const violet  = Color(0xFF9f7aea); // --luna-violet
  static const indigo  = Color(0xFF4f46e5);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const white   = Color(0xFFf0eae5);
  static const cream   = Color(0xFFd4c8be);
  static const dim     = Color(0xFF888888);
  static const dimmer  = Color(0xFF444455);
  static const border  = Color(0xFF1a1a28);

  // ── Kabbalistic House Colors (10 Sephiroth) ──────────────────────────────────
  static const kether   = Color(0xFFffffff); // Crown — pure white
  static const chokmah  = Color(0xFF9999cc); // Wisdom — blue-gray
  static const binah    = Color(0xFF000033); // Understanding — deep blue-black
  static const chesed   = Color(0xFF4466cc); // Mercy — royal blue
  static const geburah  = Color(0xFFcc2222); // Severity — red
  static const tiphareth= Color(0xFFddaa00); // Beauty — gold
  static const netzach  = Color(0xFF44aa44); // Victory — green
  static const hod      = Color(0xFFdd6600); // Splendor — orange
  static const yesod    = Color(0xFF8844cc); // Foundation — violet
  static const malkuth  = Color(0xFF6b4c3b); // Kingdom — earth brown

  static const List<Map<String, dynamic>> sephiroth = [
    {'name': 'Kether',    'meaning': 'Crown',        'color': kether,    'number': 1},
    {'name': 'Chokmah',   'meaning': 'Wisdom',       'color': chokmah,   'number': 2},
    {'name': 'Binah',     'meaning': 'Understanding', 'color': binah,    'number': 3},
    {'name': 'Chesed',    'meaning': 'Mercy',        'color': chesed,    'number': 4},
    {'name': 'Geburah',   'meaning': 'Severity',     'color': geburah,   'number': 5},
    {'name': 'Tiphareth', 'meaning': 'Beauty',       'color': tiphareth, 'number': 6},
    {'name': 'Netzach',   'meaning': 'Victory',      'color': netzach,   'number': 7},
    {'name': 'Hod',       'meaning': 'Splendor',     'color': hod,       'number': 8},
    {'name': 'Yesod',     'meaning': 'Foundation',   'color': yesod,     'number': 9},
    {'name': 'Malkuth',   'meaning': 'Kingdom',      'color': malkuth,   'number': 10},
  ];

  // ── Gradients ─────────────────────────────────────────────────────────────────
  static LinearGradient get gradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, violet],
  );


}
