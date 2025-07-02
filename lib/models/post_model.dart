
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String phoneId;
  final String phoneName;
  final String text;
  final double rating;
  final Timestamp createdAt;
  final List<String> likes;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.phoneId,
    required this.phoneName,
    required this.text,
    required this.rating,
    required this.createdAt,
    required this.likes,
  });

 
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      phoneId: data['phoneId'] ?? '',
      phoneName: data['phoneName'] ?? '',
      text: data['text'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'phoneId': phoneId,
      'phoneName': phoneName,
      'text': text,
      'rating': rating,
      'createdAt': createdAt,
      'likes': likes,
    };
  }
}