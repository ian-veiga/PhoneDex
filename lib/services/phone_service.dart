import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/phone_model.dart';

class PhoneService {
  final _phones = FirebaseFirestore.instance.collection('phones');

  Future<void> addPhone(Phone phone) async {
    await _phones.add(phone.toMap());
  }

  Future<void> updatePhone(Phone phone) async {
    await _phones.doc(phone.id).update(phone.toMap());
  }

  Future<void> deletePhone(String id) async {
    await _phones.doc(id).delete();
  }

  Stream<List<Phone>> getPhones() {
    return _phones.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Phone.fromMap(doc.data(), doc.id)).toList());
  }
}