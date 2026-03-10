import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/luna_theme.dart';

// ── Card data model ───────────────────────────────────────────────────────────

class _TarotCard {
  final String symbol;
  final String numeral;
  final String name;
  final String position;
  final String shortMeaning;
  final String interpretation;
  final double rotation; // radians

  const _TarotCard({
    required this.symbol,
    required this.numeral,
    required this.name,
    required this.position,
    required this.shortMeaning,
    required this.interpretation,
    this.rotation = 0.0,
  });
}

// ── Spread 1: Summon the Divine ───────────────────────────────────────────────

const _divine = [
  _TarotCard(
    symbol: '♚', numeral: 'I', name: 'The Father', position: 'ROOT',
    shortMeaning: 'Foundation · Structure · Authority',
    interpretation: 'Foundation, structure, authority, law, the bones of things. '
        'The ground beneath you has been stable longer than you have been watching it. '
        'The Father asks: what architecture are you standing on? '
        '"The ground is not going to give way. Trust the architecture."',
  ),
  _TarotCard(
    symbol: '✒', numeral: 'II', name: 'The Eternal Child', position: 'HEART',
    shortMeaning: 'Potential · Play · Wonder',
    rotation: -0.26, // ~-15°
    interpretation: 'Beginning, pure potential, play as prayer, imagination, wonder before calcification. '
        'The heart holds this energy at a tilt — a lean, like a question mark. '
        'Not yet fixed. Still open to becoming something entirely unexpected. '
        '"The heart doesn\'t hold this energy straight. It holds it at a tilt."',
  ),
  _TarotCard(
    symbol: '⛈', numeral: 'III', name: 'The Storm', position: 'CROWN',
    shortMeaning: 'Revelation · Disruption · Intensity',
    interpretation: 'Revelation through disruption. Clearing. Intensity that precedes transformation. '
        'The Storm at the Crown does not destroy — it illuminates what was always there. '
        'Something in your highest channels is being cracked open right now. '
        '"The divine is speaking to you right now through intensity, not through calm."',
  ),
];

// ── Spread 2: Axis Mundi ──────────────────────────────────────────────────────

const _axis = [
  _TarotCard(
    symbol: '☽', numeral: 'I', name: 'The Mother', position: 'UNDERWORLD',
    shortMeaning: 'Nourishment · Instinct · Root System',
    interpretation: 'Deep feminine, root system, mycelium, dark nourishment, instinctive intelligence. '
        'The Underworld is where things decompose and regenerate simultaneously. '
        'What you thought was decay is mycelium threading new connections beneath the surface. '
        '"The Underworld is where things decompose and regenerate."',
  ),
  _TarotCard(
    symbol: '🏇', numeral: 'II', name: 'The Hunter', position: 'PAST',
    shortMeaning: 'Momentum · Focus · Pursuit',
    rotation: -1.5708, // 90° left
    interpretation: 'Momentum, focus, single-pointed pursuit, lethal tracking instinct. '
        'Whatever you were hunting — that chase has pivoted toward the center. '
        'The energy is not gone; it has redirected. The hunter now hunts inward. '
        '"Whatever you were hunting... that chase has pivoted."',
  ),
  _TarotCard(
    symbol: '⚔', numeral: 'III', name: 'The Warrior', position: 'HEAVEN',
    shortMeaning: 'Will · Courage · Surrender',
    rotation: 3.054, // ~175° (near inverted)
    interpretation: 'Will and courage, but reversed here into surrender and earned wisdom. '
        'The Warrior who has fought enough knows when the battle is the ego\'s — not the soul\'s. '
        'The hardest fight is learning when not to fight. '
        '"The hardest fight might be the fight against fighting."',
  ),
  _TarotCard(
    symbol: '♛', numeral: 'IV', name: 'The Queen', position: 'FUTURE',
    shortMeaning: 'Sovereignty · Presence · Authority',
    rotation: 0.26, // ~15°
    interpretation: 'Sovereignty, presence, authority through being fully yourself. '
        'The future doesn\'t require you to become something radically new — '
        'it requires you to be more deeply what you already are. '
        '"The future doesn\'t require you to become something radically new."',
  ),
  _TarotCard(
    symbol: '🌍', numeral: 'V', name: 'Anima Mundi', position: 'SELF',
    shortMeaning: 'World Soul · Interconnection · Essence',
    rotation: 0.785, // 45°
    interpretation: 'World Soul. The interconnection principle made visible. '
        'You are not the point — and precisely because you are not the point, you are essential. '
        'The self at center is not the ego self; it is the self as node in a living network. '
        '"You are not the point. And precisely because you are not the point, you are essential."',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});
  @override State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealCtrl;
  int? _expandedCard; // index in _allCards for deep reading expand

  static const _gold    = Color(0xFFc9a84c);
  static const _goldDim = Color(0xFF8a7234);
  static const _cardBg1 = Color(0xFF1a1a1a);
  static const _cardBg2 = Color(0xFF0f0f0f);

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaTheme.void_,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSpreadLabel('SUMMON THE DIVINE', 'Root · Heart · Crown'),
                    const SizedBox(height: 24),
                    _DivineSpread(cards: _divine, revealCtrl: _revealCtrl, gold: _gold, cardBg1: _cardBg1, cardBg2: _cardBg2),
                    const SizedBox(height: 40),
                    _buildSpreadLabel('AXIS MUNDI', 'Underworld · Past · Heaven · Future · Self'),
                    const SizedBox(height: 24),
                    _AxisSpread(cards: _axis, revealCtrl: _revealCtrl, gold: _gold, goldDim: _goldDim, cardBg1: _cardBg1, cardBg2: _cardBg2),
                    const SizedBox(height: 40),
                    _buildDeepReadingSection(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        border: Border(bottom: BorderSide(color: LunaTheme.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            color: _goldDim,
            tooltip: 'return to dashboard',
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'ARCHETYPE READING',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 13,
                  color: _gold,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'The Wild Unknown · Kim Krans',
                style: GoogleFonts.spectral(
                  fontSize: 10, color: _goldDim, letterSpacing: 1),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40), // balance back button
        ],
      ),
    );
  }

  Widget _buildSpreadLabel(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 14,
              color: _gold,
              letterSpacing: 4,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.spectral(
            fontSize: 9, color: _goldDim, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 60,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                _gold.withValues(alpha: 0.4),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeepReadingSection() {
    final allCards = [..._divine, ..._axis];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'DEEP READING',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 13, color: _gold, letterSpacing: 4,
              fontWeight: FontWeight.w300),
          ),
        ),
        const SizedBox(height: 16),
        ...allCards.asMap().entries.map((e) => _DeepReadingTile(
          card: e.value,
          index: e.key,
          expanded: _expandedCard == e.key,
          gold: _gold,
          goldDim: _goldDim,
          onTap: () => setState(() {
            _expandedCard = _expandedCard == e.key ? null : e.key;
          }),
        )),
        const SizedBox(height: 24),
        _buildSynthesis(),
      ],
    );
  }

  Widget _buildSynthesis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LunaTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: _gold.withValues(alpha: 0.4), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYNTHESIS',
            style: GoogleFonts.spectral(
              fontSize: 9, color: _goldDim, letterSpacing: 3),
          ),
          const SizedBox(height: 10),
          Text(
            'The Father anchors; the Mother nourishes. Two pillars holding the same temple from opposite directions. '
            'Between them: the Eternal Child, the Hunter, the Warrior, the Queen — all in motion, all becoming. '
            'At center, Anima Mundi reminds you that the self is not the destination. '
            'The Storm at your Crown burns away what the Eternal Child no longer needs to carry.',
            style: GoogleFonts.spectral(
              fontSize: 12,
              color: const Color(0xFFf4f0e8).withValues(alpha: 0.75),
              height: 1.85,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Divine Spread (vertical 3-card) ──────────────────────────────────────────

class _DivineSpread extends StatelessWidget {
  final List<_TarotCard> cards;
  final AnimationController revealCtrl;
  final Color gold, cardBg1, cardBg2;
  const _DivineSpread({required this.cards, required this.revealCtrl,
      required this.gold, required this.cardBg1, required this.cardBg2});

  @override
  Widget build(BuildContext context) {
    // Crown (index 2), Heart (1), Root (0) — top to bottom
    final ordered = [cards[2], cards[1], cards[0]];
    final delays  = [0.6, 0.4, 0.2];
    return Center(
      child: SizedBox(
        width: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Connecting vertical line
            Positioned(
              top: 0, bottom: 0, left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [
                        gold.withValues(alpha: 0.3),
                        gold.withValues(alpha: 0.08),
                        gold.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: List.generate(3, (i) => Padding(
                padding: EdgeInsets.only(bottom: i < 2 ? 16 : 0),
                child: _AnimatedCard(
                  card: ordered[i],
                  delay: delays[i],
                  revealCtrl: revealCtrl,
                  gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Axis Mundi Spread (5-card cross) ─────────────────────────────────────────

class _AxisSpread extends StatelessWidget {
  final List<_TarotCard> cards;
  final AnimationController revealCtrl;
  final Color gold, goldDim, cardBg1, cardBg2;
  const _AxisSpread({required this.cards, required this.revealCtrl,
      required this.gold, required this.goldDim,
      required this.cardBg1, required this.cardBg2});

  static const _cw = 100.0;
  static const _ch = 158.0;

  @override
  Widget build(BuildContext context) {
    // cards: [Underworld, Past, Heaven, Future, Self]
    return Center(
      child: SizedBox(
        width: _cw * 3 + 24,
        height: _ch * 3 + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cross lines
            CustomPaint(
              size: Size(_cw * 3 + 24, _ch * 3 + 24),
              painter: _CrossLinePainter(gold),
            ),
            // Heaven (top center)
            Positioned(
              top: 0, left: _cw + 12,
              child: _AnimatedCard(
                card: cards[2], delay: 0.8, revealCtrl: revealCtrl,
                gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
                width: _cw, height: _ch,
              ),
            ),
            // Past (left center)
            Positioned(
              top: _ch + 12, left: 0,
              child: _AnimatedCard(
                card: cards[1], delay: 1.0, revealCtrl: revealCtrl,
                gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
                width: _cw, height: _ch,
              ),
            ),
            // Self (center)
            Positioned(
              top: _ch + 12, left: _cw + 12,
              child: _AnimatedCard(
                card: cards[4], delay: 1.2, revealCtrl: revealCtrl,
                gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
                width: _cw, height: _ch,
              ),
            ),
            // Future (right center)
            Positioned(
              top: _ch + 12, left: (_cw + 12) * 2,
              child: _AnimatedCard(
                card: cards[3], delay: 1.0, revealCtrl: revealCtrl,
                gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
                width: _cw, height: _ch,
              ),
            ),
            // Underworld (bottom center)
            Positioned(
              top: (_ch + 12) * 2, left: _cw + 12,
              child: _AnimatedCard(
                card: cards[0], delay: 0.6, revealCtrl: revealCtrl,
                gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
                width: _cw, height: _ch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrossLinePainter extends CustomPainter {
  final Color gold;
  _CrossLinePainter(this.gold);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical line
    p.shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [gold.withValues(alpha: 0.3), gold.withValues(alpha: 0.08), gold.withValues(alpha: 0.3)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), p);

    // Horizontal line
    p.shader = LinearGradient(
      begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: [gold.withValues(alpha: 0.3), gold.withValues(alpha: 0.08), gold.withValues(alpha: 0.3)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Animated Card ─────────────────────────────────────────────────────────────

class _AnimatedCard extends StatelessWidget {
  final _TarotCard card;
  final double delay;
  final AnimationController revealCtrl;
  final Color gold, cardBg1, cardBg2;
  final double width;
  final double height;

  const _AnimatedCard({
    required this.card,
    required this.delay,
    required this.revealCtrl,
    required this.gold,
    required this.cardBg1,
    required this.cardBg2,
    this.width = 110,
    this.height = 174,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: revealCtrl,
      builder: (_, child) {
        final t = ((revealCtrl.value - delay * 0.6) / 0.4).clamp(0.0, 1.0);
        final curve = Curves.easeOut.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - curve)),
            child: child,
          ),
        );
      },
      child: Transform.rotate(
        angle: card.rotation,
        child: _CardFace(card: card, gold: gold, cardBg1: cardBg1, cardBg2: cardBg2,
            width: width, height: height),
      ),
    );
  }
}

class _CardFace extends StatefulWidget {
  final _TarotCard card;
  final Color gold, cardBg1, cardBg2;
  final double width, height;
  const _CardFace({required this.card, required this.gold,
      required this.cardBg1, required this.cardBg2,
      required this.width, required this.height});
  @override State<_CardFace> createState() => _CardFaceState();
}

class _CardFaceState extends State<_CardFace> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.gold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp:   (_) => setState(() => _hover = false),
      onTapCancel: ()  => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [widget.cardBg1, widget.cardBg2, const Color(0xFF141418)],
            stops: const [0, 0.6, 1],
          ),
          border: Border.all(
            color: _hover ? g.withValues(alpha: 0.5) : g.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: _hover ? 30 : 20,
              offset: const Offset(0, 2),
            ),
            if (_hover) BoxShadow(
              color: g.withValues(alpha: 0.12),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.card.position,
              style: GoogleFonts.spectral(
                fontSize: 7, color: g.withValues(alpha: 0.35), letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text(
              widget.card.symbol,
              style: TextStyle(fontSize: widget.width * 0.28, color: g.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 6),
            Text(
              widget.card.numeral,
              style: GoogleFonts.spectral(
                fontSize: 9, color: g.withValues(alpha: 0.5), letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                widget.card.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 9, color: g, letterSpacing: 1.5,
                  fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Deep Reading Tile ─────────────────────────────────────────────────────────

class _DeepReadingTile extends StatelessWidget {
  final _TarotCard card;
  final int index;
  final bool expanded;
  final Color gold, goldDim;
  final VoidCallback onTap;

  const _DeepReadingTile({
    required this.card, required this.index, required this.expanded,
    required this.gold, required this.goldDim, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: LunaTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: expanded ? gold.withValues(alpha: 0.3) : LunaTheme.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Text(card.symbol,
                      style: TextStyle(fontSize: 18, color: gold.withValues(alpha: 0.7))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name.toUpperCase(),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 12, color: gold, letterSpacing: 2,
                            fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${index < 3 ? "DIVINE" : "AXIS"} · ${card.position}',
                          style: GoogleFonts.spectral(
                            fontSize: 8, color: goldDim, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14, color: goldDim),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: gold.withValues(alpha: 0.12)),
                    Text(
                      card.shortMeaning,
                      style: GoogleFonts.spectral(
                        fontSize: 10, color: goldDim, letterSpacing: 1),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card.interpretation,
                      style: GoogleFonts.spectral(
                        fontSize: 12,
                        color: const Color(0xFFf4f0e8).withValues(alpha: 0.75),
                        height: 1.85,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
