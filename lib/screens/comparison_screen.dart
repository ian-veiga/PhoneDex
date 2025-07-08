import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pphonedex/components/bottombar.dart';

class ComparisonScreen extends StatelessWidget {
  final String firstPhoneId;
  final String secondPhoneId;

  const ComparisonScreen({
    super.key,
    required this.firstPhoneId,
    required this.secondPhoneId,
  });

  Future<Map<String, dynamic>> fetchPhoneData(String docId) async {
    final doc =
        await FirebaseFirestore.instance.collection('phones').doc(docId).get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('📱 Comparação VS'),
        centerTitle: true,
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
          if (!snapshot.hasData || snapshot.data!.length < 2) {
            return const Center(child: Text('Erro ao carregar dados.'));
          }

          final firstData = snapshot.data![0];
          final secondData = snapshot.data![1];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagens e nomes dos celulares
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildPhoneCard(context, firstData)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 40.0),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Expanded(child: buildPhoneCard(context, secondData)),
                  ],
                ),
                const SizedBox(height: 24),

                // Seções comparativas
                buildSpecSection(
                    '🧠 RAM', firstData['ram'], secondData['ram']),
                buildSpecSection(
                    '📸 Câmera', firstData['camera'], secondData['camera']),
                buildSpecSection('💾 Armazenamento', firstData['storage'],
                    secondData['storage']),
                buildSpecSection('⚙️ Processador', firstData['processor'],
                    secondData['processor']),
                buildSpecSection('🔋 Bateria', firstData['battery'],
                    secondData['battery']),
                buildSpecSection(
                    '🎨 Cores', firstData['colors'], secondData['colors']),
                buildSpecSection('📐 Tela', firstData['screenSize'],
                    secondData['screenSize']),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  
  Widget buildPhoneCard(BuildContext context, Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Image.network(
                data['imageUrl'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  
  Widget buildSpecSection(
      String title, String? firstValue, String? secondValue) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    firstValue ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(
                  height: 20,
                  child: VerticalDivider(color: Colors.grey),
                ),
                Expanded(
                  child: Text(
                    secondValue ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
