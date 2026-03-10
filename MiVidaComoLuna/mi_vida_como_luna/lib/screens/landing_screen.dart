import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/luna_theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _starCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _starCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 60))..repeat();
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaTheme.void_,
      body: Stack(
        children: [
          // Starfield
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_starCtrl.value),
              size: Size.infinite,
            ),
          ),
          // Moon glow
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Center(
              child: Transform.translate(
                offset: const Offset(0, -80),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: LunaTheme.purple.withValues(alpha: _glowAnim.value * 0.35),
                        blurRadius: 120,
                        spreadRadius: 60,
                      ),
                      BoxShadow(
                        color: LunaTheme.violet.withValues(alpha: _glowAnim.value * 0.2),
                        blurRadius: 200,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _MoonWidget(glowAnim: _glowAnim),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildTagline(),
                  const SizedBox(height: 48),
                  _buildSephirothGrid(),
                  const SizedBox(height: 48),
                  _buildPhilosophy(),
                  const SizedBox(height: 48),
                  _EnterButton(onTap: () => Navigator.pushNamed(context, '/login')),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [LunaTheme.silver, LunaTheme.purple, LunaTheme.violet],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'Mi Vida Como Luna',
        textAlign: TextAlign.center,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 38,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          letterSpacing: 2,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'A Kabbalistic journey through lunar cycles,\narchetypes, and the architecture of the self.',
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          color: LunaTheme.dim,
          height: 1.7,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSephirothGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'THE TEN SEPHIROTH',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: LunaTheme.dim,
                letterSpacing: 3,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: LunaTheme.sephiroth.length,
            itemBuilder: (_, i) {
              final s = LunaTheme.sephiroth[i];
              final c = s['color'] as Color;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: LunaTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border(
                    left: BorderSide(color: c, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.withValues(alpha: 0.15),
                        border: Border.all(color: c.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Text(
                          '${s['number']}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9, color: c, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s['name'] as String,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 13, color: LunaTheme.white,
                              fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            s['meaning'] as String,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8, color: LunaTheme.dim),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LunaTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: LunaTheme.border),
        ),
        child: Column(
          children: [
            Text(
              '"As above, so below.\nAs within, so without."',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: LunaTheme.silver,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Track your inner tides through the lunar cycle.\nDiscover how each phase mirrors the Sephiroth.\nRead the archetypes that move through you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: LunaTheme.dim,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Moon Widget ──────────────────────────────────────────────────────────────

class _MoonWidget extends StatelessWidget {
  final Animation<double> glowAnim;
  const _MoonWidget({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LunaTheme.silver.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: LunaTheme.purple.withValues(alpha: glowAnim.value * 0.6),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: LunaTheme.silver.withValues(alpha: glowAnim.value * 0.3),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: CustomPaint(painter: _MoonPainter()),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Crescent shadow to give 3D feel
    final p = Paint()..color = LunaTheme.void_.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.5),
        width: size.width * 0.8,
        height: size.height * 0.95,
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Enter Button ─────────────────────────────────────────────────────────────

class _EnterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _EnterButton({required this.onTap});
  @override State<_EnterButton> createState() => _EnterButtonState();
}

class _EnterButtonState extends State<_EnterButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp:   (_) => setState(() => _hover = false),
      onTapCancel: ()  => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: _hover ? LunaTheme.purple : Colors.transparent,
          border: Border.all(color: LunaTheme.purple, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '[ ENTER THE CODEX ]',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: _hover ? LunaTheme.void_ : LunaTheme.purple,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Starfield Painter ─────────────────────────────────────────────────────────

class _StarfieldPainter extends CustomPainter {
  final double t;
  _StarfieldPainter(this.t);

  static final _rng = math.Random(42);
  static final _stars = List.generate(180, (_) => [
    _rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble() * 1.5 + 0.3,
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final twinkle = (math.sin((t + s[0]) * math.pi * 2) * 0.3 + 0.7);
      canvas.drawCircle(
        Offset(s[0] * size.width, s[1] * size.height),
        s[2],
        Paint()..color = LunaTheme.silver.withValues(alpha: twinkle * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.t != t;
}
