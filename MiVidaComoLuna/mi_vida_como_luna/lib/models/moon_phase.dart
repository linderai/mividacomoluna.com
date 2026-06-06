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


// ══════════════════════════════════════════════════════════════════════════════
// MOON IN ZODIAC
// ══════════════════════════════════════════════════════════════════════════════

enum MoonZodiac {
  aries, taurus, gemini, cancer, leo, virgo,
  libra, scorpio, sagittarius, capricorn, aquarius, pisces
}

extension MoonZodiacExt on MoonZodiac {
  static const _labels   = ['Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'];
  static const _glyphs   = ['♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓'];
  static const _elements = ['Fire','Earth','Air','Water','Fire','Earth','Air','Water','Fire','Earth','Air','Water'];
  static const _quality  = ['Cardinal','Fixed','Mutable','Cardinal','Fixed','Mutable','Cardinal','Fixed','Mutable','Cardinal','Fixed','Mutable'];
  static const _rulers   = ['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars · Pluto','Jupiter','Saturn','Saturn · Uranus','Jupiter · Neptune'];

  String get label   => _labels[index];
  String get glyph   => _glyphs[index];
  String get element => _elements[index];
  String get quality => _quality[index];
  String get ruler   => _rulers[index];
}

class ZodiacData {
  final MoonZodiac sign;
  final double degree; // 0–30 within sign
  const ZodiacData({required this.sign, required this.degree});
}

// ══════════════════════════════════════════════════════════════════════════════
// QLIPHOTH — shadow mirror of each phase
// ══════════════════════════════════════════════════════════════════════════════

extension QliphothExt on MoonPhase {
  bool get isWaning =>
      this == MoonPhase.waningGibbous ||
      this == MoonPhase.lastQuarter   ||
      this == MoonPhase.waningCrescent;

  String get qliphothName {
    switch (this) {
      case MoonPhase.newMoon:        return 'Thaumiel';
      case MoonPhase.waxingCrescent: return 'Ghagiel';
      case MoonPhase.firstQuarter:   return 'Satariel';
      case MoonPhase.waxingGibbous:  return "Gha'agsheblah";
      case MoonPhase.fullMoon:       return 'Thagirion';
      case MoonPhase.waningGibbous:  return 'Harab Serapel';
      case MoonPhase.lastQuarter:    return 'Samael';
      case MoonPhase.waningCrescent: return 'Gamaliel';
    }
  }

  String get qliphothMeaning {
    switch (this) {
      case MoonPhase.newMoon:
        return 'The Twin Gods. Duality fractures where there was only One. The false crown casts two shadows.';
      case MoonPhase.waxingCrescent:
        return 'The Hinderers. Wisdom scattered into noise. The divine flash becomes static.';
      case MoonPhase.firstQuarter:
        return 'The Concealers. Understanding withheld. The dark womb becomes the sealed tomb.';
      case MoonPhase.waxingGibbous:
        return 'The Smiters. Mercy without discernment. Love turns to possession; abundance to excess.';
      case MoonPhase.fullMoon:
        return 'The Disputers. Beauty inverted into discord. Harmony collapses at its own center.';
      case MoonPhase.waningGibbous:
        return 'Ravens of Death. Desire consumes what it touches. The gift becomes the wound that never closes.';
      case MoonPhase.lastQuarter:
        return 'Poison of God. Intellect weaponized against the soul. Truth becomes the blade that slanders.';
      case MoonPhase.waningCrescent:
        return 'The Obscene Ones. Foundation dissolves into illusion. The thinning veil reveals the hungry dark.';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PATH ON THE TREE OF LIFE — 32 paths, 29.53 days
// ══════════════════════════════════════════════════════════════════════════════

class TreePath {
  final int    number;       // 1–32
  final String name;         // Sephirah or Hebrew letter name
  final String? hebrewGlyph; // null for paths 1–10 (Sephiroth)
  final String? tarotCard;   // null for paths 1–10
  final String? tarotNumeral;
  final String meditation;

  const TreePath({
    required this.number,
    required this.name,
    this.hebrewGlyph,
    this.tarotCard,
    this.tarotNumeral,
    required this.meditation,
  });

  bool get isSephirah => number <= 10;
}

// ══════════════════════════════════════════════════════════════════════════════
// MOON ENGINE — extended
// ══════════════════════════════════════════════════════════════════════════════

extension MoonEngineExtended on MoonEngine {
  // Moon in Zodiac (mean longitude, tropical)
  static ZodiacData calculateZodiac([DateTime? date]) {
    final d = (date ?? DateTime.now()).toUtc();
    final j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);
    final days = d.difference(j2000).inMilliseconds / 86400000.0;
    double lng = (218.3165 + 13.17639648 * days) % 360.0;
    if (lng < 0) lng += 360.0;
    final signIdx = (lng / 30).floor().clamp(0, 11);
    return ZodiacData(
      sign:   MoonZodiac.values[signIdx],
      degree: lng % 30,
    );
  }

  // Current path on the Tree of Life (32-step cycle)
  static TreePath calculatePath([DateTime? date]) {
    final moon = MoonEngine.calculate(date);
    const synodic = 29.530588853;
    final idx = (moon.age / synodic * 32).floor().clamp(0, 31);
    return _paths[idx];
  }

  static final List<TreePath> _paths = const [
    // ── Sephiroth 1–10 ────────────────────────────────────────────────────────
    TreePath(number: 1,  name: 'Kether',
      meditation: 'Primordial light. The first cause before all causes. Pure being that cannot be named.'),
    TreePath(number: 2,  name: 'Chokmah',
      meditation: 'Raw divine force. The flash before thought. Father principle — wisdom without form.'),
    TreePath(number: 3,  name: 'Binah',
      meditation: 'The great dark sea. Form receives force. The mother womb that shapes all understanding.'),
    TreePath(number: 4,  name: 'Chesed',
      meditation: 'Divine love in boundless abundance. Structure as gift. The benevolent king who gives freely.'),
    TreePath(number: 5,  name: 'Geburah',
      meditation: 'Sacred will and focused power. The pruning flame. Justice without malice, severity with purpose.'),
    TreePath(number: 6,  name: 'Tiphareth',
      meditation: 'Harmony of all opposites. The solar heart. The self that holds the cross of matter and spirit.'),
    TreePath(number: 7,  name: 'Netzach',
      meditation: 'Desire and nature as divine expression. Astral fire. The green world where instinct is sacred.'),
    TreePath(number: 8,  name: 'Hod',
      meditation: 'Intellect and precision. Language as magic. The messenger who gives name and form to force.'),
    TreePath(number: 9,  name: 'Yesod',
      meditation: 'Lunar tides and dreaming. The etheric body. The astral mirror between worlds.'),
    TreePath(number: 10, name: 'Malkuth',
      meditation: 'The world made manifest. Earth. The bride who receives all above and makes it real.'),
    // ── 22 Paths (Hebrew Letters + Major Arcana) ──────────────────────────────
    TreePath(number: 11, name: 'Aleph',    hebrewGlyph: 'א', tarotCard: 'The Fool',          tarotNumeral: '0',
      meditation: 'Pure spirit leaping into the void. Beginnings without fear. The holy breath before the first word.'),
    TreePath(number: 12, name: 'Beth',     hebrewGlyph: 'ב', tarotCard: 'The Magician',       tarotNumeral: 'I',
      meditation: 'Will focused to a single point. The creative word spoken. All tools lie ready on the altar.'),
    TreePath(number: 13, name: 'Gimel',    hebrewGlyph: 'ג', tarotCard: 'The High Priestess', tarotNumeral: 'II',
      meditation: 'The lunar veil. Hidden knowledge sustains the revealed. What is not said holds the most power.'),
    TreePath(number: 14, name: 'Daleth',   hebrewGlyph: 'ד', tarotCard: 'The Empress',        tarotNumeral: 'III',
      meditation: 'Venus opens the doorway of abundance. Nature at her fullest. The flesh as sacred scripture.'),
    TreePath(number: 15, name: 'He',       hebrewGlyph: 'ה', tarotCard: 'The Emperor',        tarotNumeral: 'IV',
      meditation: 'Structure holds what force has built. Aries raises the throne. Form given dominion over form.'),
    TreePath(number: 16, name: 'Vau',      hebrewGlyph: 'ו', tarotCard: 'The Hierophant',     tarotNumeral: 'V',
      meditation: 'The sacred teaching passes hand to hand. Taurus grounds the divine word into living tradition.'),
    TreePath(number: 17, name: 'Zayin',    hebrewGlyph: 'ז', tarotCard: 'The Lovers',         tarotNumeral: 'VI',
      meditation: 'The eternal choice between two paths. Gemini divides to unite. Love is the path of gnosis.'),
    TreePath(number: 18, name: 'Cheth',    hebrewGlyph: 'ח', tarotCard: 'The Chariot',        tarotNumeral: 'VII',
      meditation: 'Cancer drives the chariot of light. Opposing forces harnessed. Victory belongs to directed will.'),
    TreePath(number: 19, name: 'Teth',     hebrewGlyph: 'ט', tarotCard: 'Strength',           tarotNumeral: 'VIII',
      meditation: "Leo's primal fire tamed by love. Inner dominion over appetite. The serpent power rises gently."),
    TreePath(number: 20, name: 'Yod',      hebrewGlyph: 'י', tarotCard: 'The Hermit',         tarotNumeral: 'IX',
      meditation: 'Virgo holds the lantern inward. Wisdom found in chosen solitude. The inner teacher speaks.'),
    TreePath(number: 21, name: 'Kaph',     hebrewGlyph: 'כ', tarotCard: 'Wheel of Fortune',   tarotNumeral: 'X',
      meditation: 'Jupiter spins the living wheel. The law of return in motion. Destiny is mathematics made sacred.'),
    TreePath(number: 22, name: 'Lamed',    hebrewGlyph: 'ל', tarotCard: 'Justice',            tarotNumeral: 'XI',
      meditation: 'Libra weighs without favor. The sword of truth cuts clean. Karma is neither punishment nor reward.'),
    TreePath(number: 23, name: 'Mem',      hebrewGlyph: 'מ', tarotCard: 'The Hanged Man',     tarotNumeral: 'XII',
      meditation: 'Water surrenders to stillness. The initiatory pause. New sight is born only through willing sacrifice.'),
    TreePath(number: 24, name: 'Nun',      hebrewGlyph: 'נ', tarotCard: 'Death',              tarotNumeral: 'XIII',
      meditation: 'Scorpio transforms without mercy. The great crossing. What dies in you was never truly you.'),
    TreePath(number: 25, name: 'Samekh',   hebrewGlyph: 'ס', tarotCard: 'Temperance',         tarotNumeral: 'XIV',
      meditation: 'Sagittarius flows between the vessels. Art as living alchemy. The angel of perfect measure.'),
    TreePath(number: 26, name: 'Ayin',     hebrewGlyph: 'ע', tarotCard: 'The Devil',          tarotNumeral: 'XV',
      meditation: 'Capricorn binds in matter. The chains are illusion believed. Shadow work demands to be seen.'),
    TreePath(number: 27, name: 'Pe',       hebrewGlyph: 'פ', tarotCard: 'The Tower',          tarotNumeral: 'XVI',
      meditation: 'Mars strikes the false crown from the tower. The necessary collapse. Truth arrives as lightning.'),
    TreePath(number: 28, name: 'Tzaddi',   hebrewGlyph: 'צ', tarotCard: 'The Star',           tarotNumeral: 'XVII',
      meditation: 'Aquarius pours hope renewed upon the dark earth. After the tower falls — the star holds steady.'),
    TreePath(number: 29, name: 'Qoph',     hebrewGlyph: 'ק', tarotCard: 'The Moon',           tarotNumeral: 'XVIII',
      meditation: 'Pisces in the deep. The lunar illusion shimmers. Fear is the final veil before the dawn.'),
    TreePath(number: 30, name: 'Resh',     hebrewGlyph: 'ר', tarotCard: 'The Sun',            tarotNumeral: 'XIX',
      meditation: 'Clarity rises without shadow. The solar child dances unguarded. Consciousness knows itself.'),
    TreePath(number: 31, name: 'Shin',     hebrewGlyph: 'ש', tarotCard: 'Judgement',          tarotNumeral: 'XX',
      meditation: 'The fire of awakening sounds. The trumpet is not a warning — it is an invitation. Rise.'),
    TreePath(number: 32, name: 'Tau',      hebrewGlyph: 'ת', tarotCard: 'The World',          tarotNumeral: 'XXI',
      meditation: 'Saturn completes the dance. The whole is made whole. Return and beginning were always one.'),
  ];
}
