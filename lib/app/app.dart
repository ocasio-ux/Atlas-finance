import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/auth/login_page.dart';
import '../features/splash/atlas_splash_page.dart';
import 'theme/app_theme.dart';

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Atlas',
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return snapshot.data == null
          ? const LoginPage()
          : const AtlasSplashPage();
    },
  );
}
