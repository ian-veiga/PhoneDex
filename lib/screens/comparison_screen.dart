import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComparisonScreen extends StatelessWidget {
  final String firstPhoneId;
  final String secondPhoneId;

  const ComparisonScreen({
    super.key,
    required this.firstPhoneId,
    required this.secondPhoneId,
  });

  Future<Map<String, dynamic>> fetchPhoneData(String docId) async {
    final doc = await FirebaseFirestore.instance.collection('phones').doc(docId).get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF8A80),
        title: const Text('Comparação VS'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8A80), Color(0xFFFFCDD2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait([
            fetchPhoneData(firstPhoneId),
            fetchPhoneData(secondPhoneId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Erro ao carregar dados.'));
            }

            final firstData = snapshot.data![0];
            final secondData = snapshot.data![1];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ======== Cabeçalho (Imagens + VS) Centralizado ========
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPhoneCard(firstData),
                        const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        buildPhoneCard(secondData),
                      ],
                    ),
                  ),

                  // ======== Seções das especificações ========
                  buildSpecSection('🧠 RAM', firstData['ram'], secondData['ram']),
                  buildSpecSection('📸 Câmera', firstData['camera'], secondData['camera']),
                  buildSpecSection('💾 Armazenamento', firstData['storage'], secondData['storage']),
                  buildSpecSection('⚙️ Processador', firstData['processor'], secondData['processor']),
                  buildSpecSection('🔋 Bateria', firstData['battery'], secondData['battery']),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPhoneCard(Map<String, dynamic> data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              data['imageUrl'] ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildSpecSection(String title, String? firstValue, String? secondValue) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  firstValue ?? '-',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  secondValue ?? '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
