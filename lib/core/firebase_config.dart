import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_options.dart';

class FirebaseConfig {
  static Future init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
