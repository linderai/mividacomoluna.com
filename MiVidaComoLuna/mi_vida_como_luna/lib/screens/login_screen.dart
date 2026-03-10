import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/luna_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool? _gateway;

  late AnimationController _blinkCtrl;
  late Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut));
    _checkGateway();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkGateway() async {
    final ok = await LunaAuthService.instance.healthCheck();
    if (mounted) {
      setState(() => _gateway = ok);
    }
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await LunaAuthService.instance.login(
          _userCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaTheme.void_,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Moon glyph
                Text('☽', style: TextStyle(fontSize: 48,
                    color: LunaTheme.silver.withValues(alpha: 0.8))),
                const SizedBox(height: 20),
                Text(
                  'Mi Vida Como Luna',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: LunaTheme.silver,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'THE VEIL REQUIRES YOUR SEAL',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: LunaTheme.dim,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 36),
                // Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: LunaTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(color: LunaTheme.purple, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gateway status
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _blinkAnim,
                            builder: (_, __) => Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _gateway == null
                                    ? LunaTheme.dim.withValues(alpha: _blinkAnim.value)
                                    : _gateway!
                                        ? LunaTheme.purple.withValues(alpha: _blinkAnim.value)
                                        : const Color(0xFFcc2222),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _gateway == null
                                ? '☽ THE MOON GATEKEEPER STIRS...'
                                : _gateway!
                                    ? '☽ MOON GATEKEEPER WATCHES'
                                    : '✦ GATEKEEPER BEYOND THE VEIL',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: LunaTheme.dim,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _LunaField(
                        controller: _userCtrl,
                        label: 'USERNAME',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _LunaField(
                        controller: _passCtrl,
                        label: 'PASSWORD',
                        icon: Icons.lock_outline,
                        obscure: true,
                        onSubmit: _loading ? null : _login,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: const Color(0xFFcc2222),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _LoginButton(loading: _loading, onTap: _loading ? null : _login),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    '← return to the void',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: LunaTheme.dim,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LunaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onSubmit;

  const _LunaField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9, color: LunaTheme.dim, letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13, color: LunaTheme.white),
          onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16, color: LunaTheme.dim),
            hintText: obscure ? '••••••••' : 'enter ${label.toLowerCase()}',
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: 11, color: LunaTheme.dimmer),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LunaTheme.border)),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LunaTheme.purple, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onTap;
  const _LoginButton({required this.loading, required this.onTap});
  @override State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _hover = true),
        onTapUp:   (_) => setState(() => _hover = false),
        onTapCancel: ()  => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _hover && !widget.loading ? LunaTheme.purple : Colors.transparent,
            border: Border.all(
              color: widget.loading ? LunaTheme.dimmer : LunaTheme.purple),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: LunaTheme.purple.withValues(alpha: 0.7),
                    ),
                  )
                : Text(
                    'CROSS THE THRESHOLD',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: _hover ? LunaTheme.void_ : LunaTheme.purple,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
