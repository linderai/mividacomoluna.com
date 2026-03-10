import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tarot_screen.dart';

void main() {
  runApp(const MiVidaComoLunaApp());
}

class MiVidaComoLunaApp extends StatelessWidget {
  const MiVidaComoLunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Vida Como Luna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0a0a0f),
      ),
      initialRoute: '/',
      routes: {
        '/':          (context) => const LandingScreen(),
        '/login':     (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tarot':     (context) => const TarotScreen(),
      },
    );
  }
}
