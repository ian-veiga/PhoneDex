import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pphonedex/screens/register_screen.dart';
import 'package:pphonedex/screens/splash_screen.dart';
import 'package:pphonedex/screens/login_screen.dart';
import 'package:pphonedex/screens/home_screen.dart';
import 'package:pphonedex/screens/phone_detail_screen.dart';
import 'package:pphonedex/screens/add_phone_screen.dart';
import 'package:pphonedex/screens/SelectOpponentScreen.dart';
import 'package:pphonedex/screens/profile_screen.dart'; 
import '/core/firebase_config.dart';
import 'package:pphonedex/screens/feed_screen.dart';
import 'package:pphonedex/screens/pending_phones_screen.dart'; 
import 'package:pphonedex/screens/map_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.init();
  runApp(const PhoneDexApp());
}

class PhoneDexApp extends StatelessWidget {
  const PhoneDexApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneDex',
      theme: ThemeData(
      // Paleta de Cores Principal
      primaryColor: const Color(0xFFCC0000), // Vermelho Pokédex
      scaffoldBackgroundColor: const Color(0xFFEAEAEA), // Fundo de tela neutro e claro
      // Cor de destaque para botões e elementos interativos
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.red,
      ).copyWith(
        secondary: const Color(0xFF3B4CCA), // Azul para botões/links
      ),

      // Estilo da AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.red, // Vermelho Pokédex
        elevation: 4, // Sombra sutil
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto', // Use uma fonte consistente
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Ícones brancos na AppBar
        ),
      ),

      // Estilo para FloatingActionButtons
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3B4CCA), // Azul
        foregroundColor: Colors.white,
      ),

      // Estilo dos Textos
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF1F1F1F)), // Texto principal escuro
        headlineLarge: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/details': (_) => const PhoneDetailScreen(),
        '/add_phone': (_) => AddPhoneScreen(),
        '/profile': (_) => const ProfileScreen(), 
        '/selectForVs': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SelectOpponentScreen(firstPhoneId: args['firstPhoneId']);
        },
        '/feed': (_) => const FeedScreen(),
        'pendingPhones': (_) => const PendingPhonesScreen(),
        '/map': (_) => const MapScreen(),
      },
    );
  }
}
