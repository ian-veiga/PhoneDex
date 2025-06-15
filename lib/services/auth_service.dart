import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String pass) =>
    _auth.createUserWithEmailAndPassword(email: email, password: pass).then((c)=>c.user);

  Future<User?> login(String email, String pass) =>
    _auth.signInWithEmailAndPassword(email: email, password: pass).then((c)=>c.user);

  Future<void> logout() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
