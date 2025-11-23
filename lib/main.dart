import 'package:flutter/material.dart';
import 'package:ukk_mobile_maulid/screen/login.dart';
import 'package:ukk_mobile_maulid/screen/splash.dart';
import 'package:ukk_mobile_maulid/screen/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UKK Mobile Maulid",
      theme: ThemeData(
        useMaterial3: true,
      ),
      // Splash screen sebagai halaman awal
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
