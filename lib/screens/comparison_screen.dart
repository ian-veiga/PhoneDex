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
        backgroundColor: Colors.red.shade100,
        title: const Text('Comparação VS'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildPhoneCard(firstData),
                    const Text('VS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    buildPhoneCard(secondData),
                  ],
                ),
                const SizedBox(height: 24),
                buildSpecRow('RAM', firstData['ram'], secondData['ram']),
                buildSpecRow('Câmera', firstData['camera'], secondData['camera']),
                buildSpecRow('Armazenamento', firstData['storage'], secondData['storage']),
                buildSpecRow('Processador', firstData['processor'], secondData['processor']),
                buildSpecRow('Bateria', firstData['battery'], secondData['battery']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPhoneCard(Map<String, dynamic> data) {
    return Column(
      children: [
        Image.network(
          data['imageUrl'] ?? '',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade300,
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildSpecRow(String label, String? firstValue, String? secondValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('$label: ${firstValue ?? '-'}')),
          const SizedBox(width: 16),
          Expanded(child: Text('${secondValue ?? '-'}', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
