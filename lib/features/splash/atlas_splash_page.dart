import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../home/home_page.dart';

class AtlasSplashPage extends StatefulWidget {
  const AtlasSplashPage({super.key});

  @override
  State<AtlasSplashPage> createState() => _AtlasSplashPageState();
}

class _AtlasSplashPageState extends State<AtlasSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _symbolScale;
  late final Animation<double> _symbolOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _symbolScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, .52, curve: Curves.easeOutBack)),
    );
    _symbolOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .32, curve: Curves.easeOut),
    );
    _wordmarkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.30, .68, curve: Curves.easeOut),
    );
    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, .28),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(.30, .72, curve: Curves.easeOutCubic)));
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.62, 1, curve: Curves.easeOut),
    );

    _start();
  }

  Future<void> _start() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final glow = 0.12 + (_controller.value * 0.18);
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: .72,
                    colors: [
                      AtlasColors.green.withValues(alpha: glow),
                      AtlasColors.background,
                    ],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _symbolOpacity,
                    child: ScaleTransition(
                      scale: _symbolScale,
                      child: const _AtlasMark(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _wordmarkOpacity,
                    child: SlideTransition(
                      position: _wordmarkSlide,
                      child: const Text(
                        'ATLAS',
                        style: TextStyle(
                          color: AtlasColors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 9,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: const Text(
                      'FINANCE',
                      style: TextStyle(
                        color: AtlasColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: const Text(
                      'Seu dinheiro. Sob controle.',
                      style: TextStyle(
                        color: AtlasColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtlasMark extends StatelessWidget {
  const _AtlasMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AtlasColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AtlasColors.green.withValues(alpha: .30),
            blurRadius: 42,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.public_rounded, color: Color(0x33FFFFFF), size: 72),
          Icon(Icons.account_balance_rounded, color: AtlasColors.white, size: 44),
        ],
      ),
    );
  }
}
