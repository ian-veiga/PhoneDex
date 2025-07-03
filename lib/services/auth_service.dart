import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> register(String email, String pass, String username) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    if (cred.user != null) {
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return cred.user;
  }

  Future<User?> login(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email, password: pass)
          .then((c) => c.user);

  /// 🔄 Login usando o campo 'username' salvo no Firestore
  Future<User?> loginWithUsername(String username, String password) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Usuário não encontrado');
    }

    final email = query.docs.first.data()['email'];
    return login(email, password);
  }

  Future<void> logout() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
