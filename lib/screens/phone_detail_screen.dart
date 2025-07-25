import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pphonedex/models/phone_model.dart';
import 'package:pphonedex/screens/add_phone_screen.dart';
import 'package:pphonedex/services/phone_service.dart';
import 'package:pphonedex/components/bottombar.dart';

class PhoneDetailScreen extends StatefulWidget {
  const PhoneDetailScreen({super.key});

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> {
  bool isFavorite = false;
  String? userId;
  String? docId; 
  final PhoneService _phoneService = PhoneService();

  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (docId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;

  
      if (args != null && args is Map<String, dynamic>) {
        
        if (args.containsKey('docId')) {
          setState(() {
            docId = args['docId'];
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              userId = user.uid;
              checkFavorite(docId!);
            }
          });
        }
      }
    }
  }


  Future<void> checkFavorite(String phoneId) async {
    if (userId == null) return;
    final docRef = FirebaseFirestore.instance.collection('favorites').doc('${userId!}_$phoneId');
    final doc = await docRef.get();
    if (mounted) {
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (userId == null || docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: ID do celular ou usuário não encontrado.')));
      return;
    }
    final favRef = FirebaseFirestore.instance.collection('favorites').doc('${userId!}_${docId!}');
    if (isFavorite) {
      await favRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removido dos favoritos.')));
    } else {
      await favRef.set({
        'userId': userId,
        'phoneId': docId,
        'addedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionado aos favoritos!')));
    }
    if (mounted) {
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  void _deletePhone(String phoneId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este celular?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async {
                await _phoneService.deletePhone(phoneId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Celular excluído com sucesso!')));
              },
            ),
          ],
        );
      },
    );
  }

  void startVsMode(BuildContext context) {
    if (docId != null) {
      Navigator.pushNamed(
        context,
        '/selectForVs',
        arguments: {'firstPhoneId': docId!},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se, por algum motivo, o docId ainda for nulo, mostra uma tela de erro amigável.
    if (docId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(
          child: Text('Não foi possível carregar os detalhes do celular. ID não fornecido.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('📱 Detalhes do Celular'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00000000), Color(0x00000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('phones').doc(docId!).get(),
          builder: (context, snapshot) {
            // ... (o resto do seu código continua igual)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Celular não encontrado'));
            }

            final phone = Phone.fromMap(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
            final isOwner = phone.userId == userId;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      phone.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          phone.imageUrl,
                          height: 230,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInfoCard('🧠 RAM', phone.ram),
                        _buildSpacing(),
                        _buildInfoCard('📸 Câmera', phone.camera),
                        _buildSpacing(),
                        _buildInfoCard('💾 Armazenamento', phone.storage),
                        _buildSpacing(),
                        _buildInfoCard('⚙️ Processador', phone.processor),
                        _buildSpacing(),
                        _buildInfoCard('🔋 Bateria', phone.battery),
                        _buildSpacing(),
                        _buildInfoCard('🎨 Cores', phone.colors),
                        _buildSpacing(),
                        _buildInfoCard('📐 Tamanho da Tela', phone.screenSize),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: toggleFavorite,
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            label: Text(
                              isFavorite ? 'Favorito' : 'Favoritar',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => startVsMode(context),
                            icon: const Icon(Icons.sports_martial_arts, color: Colors.white),
                            label: const Text(
                              'VS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isOwner) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => AddPhoneScreen(phoneToEdit: phone),
                                ));
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text('Editar', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _deletePhone(phone.id),
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: const Text('Excluir', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
       bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildInfoCard(String title, String? value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value ?? '-', style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildSpacing() => const SizedBox(height: 12);
}