import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pphonedex/components/bottombar.dart';
import 'comparison_screen.dart';

class SelectOpponentScreen extends StatelessWidget {
  final String firstPhoneId;

  const SelectOpponentScreen({super.key, required this.firstPhoneId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo e AppBar alinhados com o tema do app
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Selecione o Oponente'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // MODIFICAÇÃO: Busca apenas celulares com status 'approved'
        stream: FirebaseFirestore.instance
            .collection('phones')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum celular encontrado.'));
          }

          // Filtra o celular já selecionado para não aparecer na lista de oponentes
          final phones =
              snapshot.data!.docs.where((doc) => doc.id != firstPhoneId).toList();

          if (phones.isEmpty) {
            return const Center(
                child: Text('Nenhum outro celular disponível para comparar.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: phones.length,
            itemBuilder: (context, index) {
              final doc = phones[index];
              final data = doc.data() as Map<String, dynamic>;

              // O item da lista já parece um card, mantendo o estilo
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComparisonScreen(
                        firstPhoneId: firstPhoneId,
                        secondPhoneId: doc.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['imageUrl'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            data['name'] ?? 'Sem nome',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Adiciona a barra inferior para consistência
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
