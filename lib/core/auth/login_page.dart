import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../features/splash/atlas_logo.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = AuthService();
  bool loading = false;
  String? error;

  Future<void> _signIn() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await auth.signInWithGoogle();
    } catch (_) {
      if (!mounted) return;
      setState(() => error = 'Não foi possível entrar com o Google.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AtlasColors.background,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AtlasLogo(size: 96),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo ao Atlas',
                style: TextStyle(color: AtlasColors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entre para acessar suas finanças em qualquer aparelho.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AtlasColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: loading ? null : _signIn,
                  icon: loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login_rounded),
                  label: Text(loading ? 'Entrando...' : 'Continuar com Google'),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error!, style: const TextStyle(color: AtlasColors.expense)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
