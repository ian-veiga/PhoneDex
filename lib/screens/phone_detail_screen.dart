import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneDetailScreen extends StatelessWidget {
  const PhoneDetailScreen({super.key});

  Future<void> addToFavorites(String phoneId) async {
    await FirebaseFirestore.instance.collection('favorites').doc(phoneId).set({
      'phoneId': phoneId,
      'addedAt': Timestamp.now(),
    });
  }

  void startVsMode(BuildContext context, String currentPhoneId) {
    Navigator.pushNamed(
      context,
      '/selectForVs',
      arguments: {'firstPhoneId': currentPhoneId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String docId = args['docId'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCDD2),
        title: const Text('Detalhes do Celular'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('phones').doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Celular não encontrado'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['imageUrl'],
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RAM: ${data['ram'] ?? ''}'),
                        Text('Câmera: ${data['camera'] ?? ''}'),
                        Text('Armazenamento: ${data['storage'] ?? ''}'),
                        Text('Processador: ${data['processor'] ?? ''}'),
                        Text('Bateria: ${data['battery'] ?? ''}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await addToFavorites(docId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Adicionado aos favoritos!')),
                          );
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Favoritar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          startVsMode(context, docId);
                        },
                        icon: const Icon(Icons.sports_martial_arts),
                        label: const Text('VS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
