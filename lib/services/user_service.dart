import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<void> create(UserModel u) => _col.doc(u.uid).set(u.toJson());
  Future<UserModel?> read(String uid) async {
    final s = await _col.doc(uid).get();
    return s.exists ? UserModel.fromJson(s.data()!) : null;
  }
  Future<void> update(UserModel u) => _col.doc(u.uid).update(u.toJson());
  Future<void> delete(String uid) => _col.doc(uid).delete();
}
