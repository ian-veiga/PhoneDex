import 'package:flutter/material.dart';
import 'package:pphonedex/screens/register_screen.dart';
import 'package:pphonedex/screens/splash_screen.dart';
import 'package:pphonedex/components/custom_bottom_bar.dart';
import 'package:pphonedex/screens/login_screen.dart';
import 'package:pphonedex/screens/home_screen.dart';


void main() {
  runApp(const PhoneDexApp());
}

class PhoneDexApp extends StatelessWidget {
  const PhoneDexApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneDex',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFD0D0D0),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}







