import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // --- INÍCIO DA MODIFICAÇÃO: Lógica do Singleton ---

  // 1. Cria uma instância privada e estática
  static final AuthService _instance = AuthService._internal();

  // 2. Cria um "factory constructor" que sempre retorna a mesma instância
  factory AuthService() {
    return _instance;
  }

  // 3. Cria um construtor interno privado
  AuthService._internal();

  // --- FIM DA MODIFICAÇÃO ---


  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool isAdmin = false;

  Future<void> _checkAdminStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      isAdmin = false;
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('isAdmin')) {
        // Garante que o valor seja tratado como booleano
        isAdmin = doc.data()!['isAdmin'] == true;
      } else {
        isAdmin = false;
      }
    } catch (e) {
      isAdmin = false;
      print("Erro ao checar status de admin: $e"); // Adicionado para depuração
    }
  }

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
        'isAdmin': false,
      });
    }
    return cred.user;
  }

  Future<User?> login(String email, String pass) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
    if (cred.user != null) {
      await _checkAdminStatus();
    }
    return cred.user;
  }

  Future<void> logout() async {
    isAdmin = false;
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}