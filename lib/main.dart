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
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFD0D0D0),
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
      },
    );
  }
}
