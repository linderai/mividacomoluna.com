import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/luna_theme.dart';
import '../services/auth_service.dart';
import '../models/moon_phase.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  late Timer _clockTimer;
  String _time = '';

  late MoonData _moon;
  late ZodiacData _zodiac;
  late TreePath _path;
  late DateTime _nextNew;
  late DateTime _nextFull;
  late DateTime _nextFirst;
  late DateTime _nextLast;

  @override
  void initState() {
    super.initState();
    // Guard: redirect to landing if not authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!LunaAuthService.instance.loggedIn) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _refreshMoon();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) { _updateTime(); }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = '${now.hour.toString().padLeft(2,'0')}:'
              '${now.minute.toString().padLeft(2,'0')}:'
              '${now.second.toString().padLeft(2,'0')}';
    });
  }

  void _refreshMoon() {
    _moon    = MoonEngine.calculate();
    _zodiac  = MoonEngineExtended.calculateZodiac();
    _path    = MoonEngineExtended.calculatePath();
    _nextNew   = MoonEngine.nextNewMoon();
    _nextFull  = MoonEngine.nextFullMoon();
    _nextFirst = MoonEngine.nextFirstQuarter();
    _nextLast  = MoonEngine.nextLastQuarter();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  void _logout() {
    LunaAuthService.instance.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = LunaAuthService.instance.username ?? 'seeker';
    return Scaffold(
      backgroundColor: LunaTheme.void_,
      body: Column(
        children: [
          _StatusBar(username: user, time: _time, onLogout: _logout),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingSection(username: user, moon: _moon),
                  const SizedBox(height: 20),
                  _MoonDisplayCard(moon: _moon, glowAnim: _glowAnim),
                  const SizedBox(height: 20),
                  _UpcomingPhasesCard(
                    nextNew: _nextNew,
                    nextFull: _nextFull,
                    nextFirst: _nextFirst,
                    nextLast: _nextLast,
                  ),
                  const SizedBox(height: 20),
                  _KabbalisticInsight(moon: _moon),
                  const SizedBox(height: 20),
                  _ShadowCard(moon: _moon),
                  const SizedBox(height: 20),
                  _ZodiacCard(zodiac: _zodiac),
                  const SizedBox(height: 20),
                  _TreePathCard(path: _path, moonAge: _moon.age),
                  const SizedBox(height: 20),
                  _PortalsGrid(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Bar ────────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final String username;
  final String time;
  final VoidCallback onLogout;
  const _StatusBar({required this.username, required this.time, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: LunaTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('☽', style: TextStyle(color: LunaTheme.silver, fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            'LUNA',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10, color: LunaTheme.purple, letterSpacing: 2,
              fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 16, color: LunaTheme.border),
          const SizedBox(width: 12),
          Text(
            username,
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: LunaTheme.dim),
          ),
          const Spacer(),
          Text(
            time,
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: LunaTheme.dimmer),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onLogout,
            child: Text(
              'LOGOUT',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9, color: LunaTheme.dim,
                decoration: TextDecoration.underline,
                decorationColor: LunaTheme.dim),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  final String username;
  final MoonData moon;
  const _GreetingSection({required this.username, required this.moon});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 6)  { return 'In the deep of night'; }
    if (h < 12) { return 'Good morning'; }
    if (h < 18) { return 'Good afternoon'; }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting, $username.',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontStyle: FontStyle.italic,
            color: LunaTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tonight is ${moon.phase.label} — ${(moon.illumination * 100).toStringAsFixed(0)}% illuminated.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10, color: LunaTheme.dim),
        ),
      ],
    );
  }
}

// ── Moon Display Card ─────────────────────────────────────────────────────────

class _MoonDisplayCard extends StatelessWidget {
  final MoonData moon;
  final Animation<double> glowAnim;
  const _MoonDisplayCard({required this.moon, required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LunaTheme.border),
      ),
      child: Row(
        children: [
          // Animated moon glyph
          AnimatedBuilder(
            animation: glowAnim,
            builder: (_, __) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: LunaTheme.purple.withValues(alpha: glowAnim.value * 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  moon.phase.glyph,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moon.phase.label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: LunaTheme.purple,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Day ${moon.age.toStringAsFixed(1)} of cycle',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18, color: LunaTheme.white),
                ),
                const SizedBox(height: 8),
                // Illumination bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ILLUMINATION',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8, color: LunaTheme.dim, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: moon.illumination,
                        backgroundColor: LunaTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LunaTheme.purple.withValues(alpha: 0.8)),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(moon.illumination * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9, color: LunaTheme.silver),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Phases ───────────────────────────────────────────────────────────

class _UpcomingPhasesCard extends StatelessWidget {
  final DateTime nextNew, nextFull, nextFirst, nextLast;
  const _UpcomingPhasesCard({
    required this.nextNew,
    required this.nextFull,
    required this.nextFirst,
    required this.nextLast,
  });

  @override
  Widget build(BuildContext context) {
    final phases = [
      ('🌑', 'New Moon',      nextNew),
      ('🌓', 'First Quarter', nextFirst),
      ('🌕', 'Full Moon',     nextFull),
      ('🌗', 'Last Quarter',  nextLast),
    ]..sort((a, b) => (a.$3).compareTo(b.$3));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LunaTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPCOMING PHASES',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9, color: LunaTheme.dim, letterSpacing: 3),
          ),
          const SizedBox(height: 12),
          ...phases.map((p) {
            final days = p.$3.difference(DateTime.now()).inDays;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(p.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.$2,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14, color: LunaTheme.cream),
                    ),
                  ),
                  Text(
                    MoonEngine.formatDate(p.$3),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9, color: LunaTheme.dim),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: LunaTheme.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: LunaTheme.purple.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'in $days d',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8, color: LunaTheme.purple),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Kabbalistic Insight ───────────────────────────────────────────────────────

class _KabbalisticInsight extends StatelessWidget {
  final MoonData moon;
  const _KabbalisticInsight({required this.moon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: LunaTheme.violet, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KABBALISTIC INSIGHT',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9, color: LunaTheme.violet, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Text(
            moon.phase.kabbalisticMeaning,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: LunaTheme.cream,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Portals Grid ──────────────────────────────────────────────────────────────

class _PortalsGrid extends StatelessWidget {
  const _PortalsGrid();

  static const _portals = [
    {'icon': '🃏', 'label': 'Tarot',          'desc': 'Daily card readings aligned with lunar phase',   'locked': false, 'route': '/tarot'},
    {'icon': '🖤', 'label': 'Dark Valentine',  'desc': 'Shadow work journal through love archetypes',   'locked': true,  'route': ''},
    {'icon': '👁',  'label': 'Entities',        'desc': 'Archetypal beings that move through your chart','locked': true,  'route': ''},
    {'icon': '📖', 'label': 'App Reader',      'desc': 'Your personal lunar codex and reflections',     'locked': false, 'route': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PORTALS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9, color: LunaTheme.dim, letterSpacing: 3),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _portals.length,
          itemBuilder: (_, i) => _PortalCard(portal: _portals[i]),
        ),
      ],
    );
  }
}

class _PortalCard extends StatefulWidget {
  final Map<String, dynamic> portal;
  const _PortalCard({required this.portal});
  @override State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final locked = widget.portal['locked'] as bool;
    return GestureDetector(
      onTap: () {
        if (locked) {
          _showUpgrade(context);
        } else {
          final route = widget.portal['route'] as String? ?? '';
          if (route.isNotEmpty) { Navigator.pushNamed(context, route); }
        }
      },
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp:   (_) => setState(() => _hover = false),
      onTapCancel: ()  => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hover ? LunaTheme.bg2 : LunaTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hover ? LunaTheme.purple.withValues(alpha: 0.5) : LunaTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.portal['icon'] as String,
                    style: const TextStyle(fontSize: 22)),
                const Spacer(),
                if (locked)
                  Icon(Icons.lock_outline, size: 12, color: LunaTheme.dim),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.portal['label'] as String,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                color: locked ? LunaTheme.dim : LunaTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                widget.portal['desc'] as String,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8.5,
                  color: LunaTheme.dimmer,
                  height: 1.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgrade(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: LunaTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '☽ PREMIUM PORTAL ☽',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  color: LunaTheme.silver,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This portal is reserved for full Codex members.\nUpgrade to access all lunar archetypes.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, color: LunaTheme.dim, height: 1.7),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: LunaTheme.purple),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'UPGRADE MEMBERSHIP',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, color: LunaTheme.purple, letterSpacing: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'maybe later',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9, color: LunaTheme.dim),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shadow Card (Qliphoth) ────────────────────────────────────────────────────

class _ShadowCard extends StatelessWidget {
  final MoonData moon;
  const _ShadowCard({required this.moon});

  @override
  Widget build(BuildContext context) {
    final waning  = moon.phase.isWaning;
    final borderC = waning ? const Color(0xFFcc2222) : const Color(0xFF441111);
    final labelC  = waning ? const Color(0xFFcc4444) : LunaTheme.dimmer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderC, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                waning ? 'SHADOW · QLIPHOTH · ACTIVE' : 'SHADOW · QLIPHOTH · DORMANT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9, color: labelC, letterSpacing: 2),
              ),
              const Spacer(),
              Text(
                moon.phase.qliphothName,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: waning ? const Color(0xFFcc4444) : LunaTheme.dimmer,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            moon.phase.qliphothMeaning,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: waning ? const Color(0xFFd4a0a0) : LunaTheme.dimmer,
              height: 1.6,
            ),
          ),
          if (!waning) ...[
            const SizedBox(height: 8),
            Text(
              'Shadow work deepens as the moon wanes.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8, color: LunaTheme.dimmer),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Zodiac Card ───────────────────────────────────────────────────────────────

class _ZodiacCard extends StatelessWidget {
  final ZodiacData zodiac;
  const _ZodiacCard({required this.zodiac});

  Color get _elementColor {
    switch (zodiac.sign.element) {
      case 'Fire':  return const Color(0xFFcc4422);
      case 'Earth': return LunaTheme.malkuth;
      case 'Air':   return LunaTheme.chokmah;
      case 'Water': return LunaTheme.yesod;
      default:      return LunaTheme.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deg = zodiac.degree.floor();
    final min = ((zodiac.degree - deg) * 60).floor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _elementColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOON IN ZODIAC',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9, color: _elementColor.withValues(alpha: 0.8),
              letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                zodiac.sign.glyph,
                style: TextStyle(fontSize: 36, color: _elementColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zodiac.sign.label.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      color: LunaTheme.white,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$deg°${min.toString().padLeft(2,"0")}′  ·  ${zodiac.sign.element}  ·  ${zodiac.sign.quality}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9, color: LunaTheme.dim),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ZodiacPill('Ruler', zodiac.sign.ruler, _elementColor),
              const SizedBox(width: 8),
              _ZodiacPill('Element', zodiac.sign.element, _elementColor),
              const SizedBox(width: 8),
              _ZodiacPill('Mode', zodiac.sign.quality, _elementColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZodiacPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ZodiacPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(fontSize: 7, color: LunaTheme.dim, letterSpacing: 1)),
          const SizedBox(height: 1),
          Text(value,
            style: GoogleFonts.jetBrainsMono(fontSize: 8, color: color.withValues(alpha: 0.9))),
        ],
      ),
    );
  }
}

// ── Tree Path Card ────────────────────────────────────────────────────────────

class _TreePathCard extends StatelessWidget {
  final TreePath path;
  final double moonAge;
  const _TreePathCard({required this.path, required this.moonAge});

  @override
  Widget build(BuildContext context) {
    const gold = LunaTheme.tiphareth;
    final progress = moonAge / 29.53;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: const BorderSide(color: gold, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PATH ON THE TREE OF LIFE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9, color: gold.withValues(alpha: 0.8),
                  letterSpacing: 2),
              ),
              const Spacer(),
              Text(
                '${path.number}/32',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9, color: LunaTheme.dim),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: LunaTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(gold),
              minHeight: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (path.hebrewGlyph != null)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: gold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      path.hebrewGlyph!,
                      style: const TextStyle(
                        fontSize: 30,
                        color: gold,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: gold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                    color: gold.withValues(alpha: 0.05),
                  ),
                  child: Center(
                    child: Text(
                      '${path.number}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18, color: gold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (path.tarotCard != null)
                      Row(
                        children: [
                          Text(
                            path.tarotNumeral!,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 12,
                              color: gold.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            path.tarotCard!.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: gold,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        path.name.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: gold,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      path.isSephirah ? 'Sephirah ${path.number} · ${path.name}' : 'Path ${path.number} · ${path.name}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8, color: LunaTheme.dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            path.meditation,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: LunaTheme.cream,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
