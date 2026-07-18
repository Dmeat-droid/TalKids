import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/services/score_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScoreService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalKids',
      debugShowCheckedModeBanner: false,
      theme: KidTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
