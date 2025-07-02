import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final _postsCollection = FirebaseFirestore.instance.collection('posts');

  // Busca todos os posts em ordem de criação
  Stream<List<Post>> getPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Adiciona um novo post
  Future<void> addPost(Post post) {
    return _postsCollection.add(post.toMap());
  }

  // Adicionar/remover like
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _postsCollection.doc(postId);
    final doc = await docRef.get();

    if (doc.exists) {
      List<String> likes = List<String>.from(doc.data()?['likes'] ?? []);
      if (likes.contains(userId)) {
        // Se já curtiu, remove o like
        docRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        // Se não curtiu, adiciona o like
        docRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    }
  }
}