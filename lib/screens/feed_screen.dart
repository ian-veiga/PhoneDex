// feed_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pphonedex/models/post_model.dart';
import 'package:pphonedex/services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final user = FirebaseAuth.instance.currentUser;

  void _openCreatePostModal({Post? post}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CreatePostModal(existingPost: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Reviews'),
        backgroundColor: const Color.fromARGB(255, 173, 76, 76),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma publicação encontrada.'));
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                isOwner: post.userId == user?.uid,
                onEdit: () => _openCreatePostModal(post: post),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePostModal,
        child: const Icon(Icons.add_comment),
        tooltip: 'Criar nova postagem',
      ),
    );
  }
}

class CreatePostModal extends StatefulWidget {
  final Post? existingPost;
  const CreatePostModal({super.key, this.existingPost});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int _rating = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      _textController.text = widget.existingPost!.text;
      _linkController.text = widget.existingPost!.link;
      _phoneController.text = widget.existingPost!.phoneName;
      _rating = widget.existingPost!.rating.toInt();
    }
  }

  Future<void> _submitPost() async {
    if (_textController.text.isEmpty && _linkController.text.isEmpty) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final username = doc.data()?['username'] ?? user?.displayName ?? 'Anônimo';

    final post = Post(
      id: widget.existingPost?.id ?? const Uuid().v4(),
      userId: user!.uid,
      userName: username,
      userPhotoUrl: user!.photoURL ?? '',
      phoneId: _phoneController.text.trim().toLowerCase().replaceAll(' ', '_'),
      phoneName: _phoneController.text.trim(),
      text: _textController.text.trim(),
      link: _linkController.text.trim(),
      rating: _rating.toDouble(),
      createdAt: widget.existingPost?.createdAt ?? Timestamp.now(),
      likes: widget.existingPost?.likes ?? [],
    );

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .set(post.toMap());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.existingPost != null ? 'Editar Postagem' : 'Nova Postagem',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nome do celular (opcional)',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Escreva um review ou comentário'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _linkController,
            decoration: const InputDecoration(labelText: 'Link de celular ou notícia (opcional)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                _rating > index ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            )),
          ),
          ElevatedButton(
            onPressed: _submitPost,
            child: Text(widget.existingPost != null ? 'Atualizar' : 'Publicar'),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final bool isOwner;
  final VoidCallback? onEdit;
  const PostCard({super.key, required this.post, required this.isOwner, this.onEdit});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(user?.uid);
  }

  void _toggleLike() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    setState(() => isLiked = !isLiked);
    await postRef.update({
      'likes': isLiked
          ? FieldValue.arrayUnion([user!.uid])
          : FieldValue.arrayRemove([user!.uid])
    });
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final username = userDoc.data()?['username'] ?? user?.displayName ?? 'Anônimo';

    final comment = {
      'userId': user!.uid,
      'userName': username,
      'text': _commentController.text.trim(),
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .add(comment);

    _commentController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.post.userPhotoUrl.isNotEmpty
                      ? NetworkImage(widget.post.userPhotoUrl)
                      : null,
                  child: widget.post.userPhotoUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (widget.isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: widget.onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deletado')),
                      );
                    },
                  ),
                ]
              ],
            ),
            if (widget.post.phoneName.isNotEmpty)
              Text('Avaliou ${widget.post.phoneName}', style: const TextStyle(color: Colors.grey)),
            if (widget.post.rating > 0)
              Row(
                children: List.generate(5, (index) => Icon(
                  index < widget.post.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                )),
              ),
            if (widget.post.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.post.text),
            ],
            if (widget.post.link.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.post.link, style: const TextStyle(color: Colors.blue)),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.post.likes.length} curtidas"),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  ),
                  onPressed: _toggleLike,
                ),
              ],
            ),
            const Divider(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      dense: true,
                      title: Text(data['userName'] ?? 'Anônimo'),
                      subtitle: Text(data['text'] ?? ''),
                    );
                  }).toList(),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Comentar...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
