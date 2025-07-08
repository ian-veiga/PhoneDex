import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/phone_model.dart';

class PhoneService {
  final _phones = FirebaseFirestore.instance.collection('phones');
  final _favorites = FirebaseFirestore.instance.collection('favorites');
  final _firestore = FirebaseFirestore.instance;

  // Busca todos os celulares aprovados
  Stream<List<Phone>> getPhones() {
    return _firestore
        .collection('phones')
        .where('status', isEqualTo: 'approved') // Alterado de 'aprovado' para 'approved'
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Phone.fromMap(doc.data(), doc.id)).toList());
  }

  // Busca apenas celulares pendentes para o admin
  Stream<List<Phone>> getPendingPhones() {
    return _firestore
        .collection('phones')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Phone.fromMap(doc.data(), doc.id)).toList());
  }

  // Aprova um celular pendente
  Future<void> approvePhone(String phoneId) {
    return _firestore.collection('phones').doc(phoneId).update({
      'status': 'approved',
    });
  }

  Future<void> addPhone(Phone phone) async {
    await _phones.add(phone.toMap());
  }

  Future<void> updatePhone(Phone phone) async {
    await _phones.doc(phone.id).update(phone.toMap());
  }

  Future<void> deletePhone(String id) async {
    await _phones.doc(id).delete();
  }

  // Esta função busca os celulares favoritos do usuário.
  Stream<List<Phone>> getFavoritePhones(String userId) {
    return _favorites
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final phoneIds = snapshot.docs.map((doc) => doc['phoneId'] as String).toList();

      if (phoneIds.isEmpty) return [];

      // Importante: Busca os favoritos apenas entre os celulares aprovados
      final phonesQuery = await _phones
          .where(FieldPath.documentId, whereIn: phoneIds)
          .where('status', isEqualTo: 'approved')
          .get();

      return phonesQuery.docs
          .map((doc) => Phone.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}