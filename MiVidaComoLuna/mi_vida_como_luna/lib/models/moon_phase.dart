import 'dart:math' as math;

enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

extension MoonPhaseExt on MoonPhase {
  String get label {
    switch (this) {
      case MoonPhase.newMoon:        return 'New Moon';
      case MoonPhase.waxingCrescent: return 'Waxing Crescent';
      case MoonPhase.firstQuarter:   return 'First Quarter';
      case MoonPhase.waxingGibbous:  return 'Waxing Gibbous';
      case MoonPhase.fullMoon:       return 'Full Moon';
      case MoonPhase.waningGibbous:  return 'Waning Gibbous';
      case MoonPhase.lastQuarter:    return 'Last Quarter';
      case MoonPhase.waningCrescent: return 'Waning Crescent';
    }
  }

  String get glyph {
    switch (this) {
      case MoonPhase.newMoon:        return '🌑';
      case MoonPhase.waxingCrescent: return '🌒';
      case MoonPhase.firstQuarter:   return '🌓';
      case MoonPhase.waxingGibbous:  return '🌔';
      case MoonPhase.fullMoon:       return '🌕';
      case MoonPhase.waningGibbous:  return '🌖';
      case MoonPhase.lastQuarter:    return '🌗';
      case MoonPhase.waningCrescent: return '🌘';
    }
  }

  String get kabbalisticMeaning {
    switch (this) {
      case MoonPhase.newMoon:        return 'Kether — The Crown. Silence before creation.';
      case MoonPhase.waxingCrescent: return 'Chokmah — Wisdom awakens. Intention sets.';
      case MoonPhase.firstQuarter:   return 'Binah — Understanding the obstacle. Act.';
      case MoonPhase.waxingGibbous:  return 'Chesed — Mercy flows. Refine your work.';
      case MoonPhase.fullMoon:       return 'Tiphareth — Beauty at peak. Full illumination.';
      case MoonPhase.waningGibbous:  return 'Netzach — Victory integrates. Share the gift.';
      case MoonPhase.lastQuarter:    return 'Hod — Splendor releases. Let form dissolve.';
      case MoonPhase.waningCrescent: return 'Yesod — Foundation rests. Return to void.';
    }
  }
}

class MoonData {
  final MoonPhase phase;
  final double illumination; // 0.0 – 1.0
  final double age;          // days since new moon (0 – 29.53)
  final DateTime date;

  const MoonData({
    required this.phase,
    required this.illumination,
    required this.age,
    required this.date,
  });
}

class MoonEngine {
  // Synodic period & reference epoch (2000-01-06 18:14 UTC ≈ known new moon)
  static const double _synodic = 29.530588853;
  static final DateTime _epoch = DateTime.utc(2000, 1, 6, 18, 14);

  static MoonData calculate([DateTime? date]) {
    final now = date ?? DateTime.now().toUtc();
    final diff = now.difference(_epoch).inSeconds / 86400.0;
    final age  = diff % _synodic;
    final frac = age / _synodic; // 0.0 – 1.0

    // Illumination via cosine approximation
    final illum = (1.0 - math.cos(2 * math.pi * frac)) / 2.0;

    // Phase buckets
    final MoonPhase phase;
    if (frac < 0.0625 || frac >= 0.9375) {
      phase = MoonPhase.newMoon;
    } else if (frac < 0.1875) {
      phase = MoonPhase.waxingCrescent;
    } else if (frac < 0.3125) {
      phase = MoonPhase.firstQuarter;
    } else if (frac < 0.4375) {
      phase = MoonPhase.waxingGibbous;
    } else if (frac < 0.5625) {
      phase = MoonPhase.fullMoon;
    } else if (frac < 0.6875) {
      phase = MoonPhase.waningGibbous;
    } else if (frac < 0.8125) {
      phase = MoonPhase.lastQuarter;
    } else {
      phase = MoonPhase.waningCrescent;
    }

    return MoonData(phase: phase, illumination: illum, age: age, date: now);
  }

  // Next occurrence of a target phase fraction (0=new, 0.5=full)
  static DateTime nextPhase(double targetFrac, [DateTime? from]) {
    final now  = from ?? DateTime.now().toUtc();
    final diff = now.difference(_epoch).inSeconds / 86400.0;
    final cur  = diff % _synodic;
    double daysAhead = (targetFrac * _synodic - cur) % _synodic;
    if (daysAhead < 0.5) daysAhead += _synodic;
    return now.add(Duration(seconds: (daysAhead * 86400).round()));
  }

  static DateTime nextNewMoon([DateTime? from])  => nextPhase(0.0, from);
  static DateTime nextFullMoon([DateTime? from]) => nextPhase(0.5, from);
  static DateTime nextFirstQuarter([DateTime? from]) => nextPhase(0.25, from);
  static DateTime nextLastQuarter([DateTime? from])  => nextPhase(0.75, from);

  static String formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
