// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pphonedex/models/post_model.dart';
import 'package:pphonedex/services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:pphonedex/components/bottombar.dart';

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
      backgroundColor: Colors.white, // Fundo branco para o modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CreatePostModal(existingPost: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo da tela consistente com as outras
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // O título e a cor agora vêm do ThemeData em main.dart
        title: const Text('Feed de Reviews'),
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
            return const Center(
              child: Text(
                'Nenhuma publicação encontrada.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        tooltip: 'Criar nova postagem',
        // Estilo já vem do tema, mas podemos garantir o ícone
        child: const Icon(Icons.add_comment),
      ),
      // Adicionando a CustomBottomBar
      bottomNavigationBar: const CustomBottomBar(),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existingPost != null ? 'Editar Postagem' : 'Nova Postagem',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nome do celular (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Escreva um review ou comentário',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                _rating > index ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 30,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            )),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitPost,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
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
    FocusScope.of(context).unfocus(); // Esconde o teclado
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (widget.post.phoneName.isNotEmpty)
                        Text('Avaliou: ${widget.post.phoneName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                if (widget.isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: widget.onEdit,
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Excluir',
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
            const SizedBox(height: 8),
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
              Text(widget.post.text, style: const TextStyle(fontSize: 15)),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.post.likes.length} curtidas"),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: isLiked ? Theme.of(context).colorScheme.secondary : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
              ],
            ),
            // Seção de Comentários
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .limit(2) // Limita a 2 comentários para não poluir
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                return Column(
                  children: [
                    const Divider(),
                    ...snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${data['userName'] ?? 'Anônimo'}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(child: Text(data['text'] ?? '')),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration.collapsed(hintText: 'Adicionar um comentário...'),
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