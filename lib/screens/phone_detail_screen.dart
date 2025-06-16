import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneDetailScreen extends StatelessWidget {
  const PhoneDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String docId = args['docId'];

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Celular')),
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                  Image.network(data['imageUrl'], height: 200),
                const SizedBox(height: 16),
                Text('RAM: ${data['ram'] ?? ''}'),
                Text('Câmera: ${data['camera'] ?? ''}'),
                Text('Armazenamento: ${data['storage'] ?? ''}'),
                Text('Processador: ${data['processor'] ?? ''}'),
                Text('Bateria: ${data['battery'] ?? ''}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
