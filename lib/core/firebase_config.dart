import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future init() async {
    await Firebase.initializeApp();
  }
  }