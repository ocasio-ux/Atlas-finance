import 'package:flutter/material.dart';

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
      home: const AtlasSplashPage(),
    );
  }
}
