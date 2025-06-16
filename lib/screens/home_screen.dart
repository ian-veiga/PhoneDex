// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:pphonedex/components/bottombar.dart';
import 'package:pphonedex/components/sidebar.dart';
import 'package:pphonedex/components/topbar.dart';
import 'package:pphonedex/screens/add_phone_screen.dart';
import 'package:pphonedex/services/phone_service.dart'; // Importe o serviço de telefone
import 'package:pphonedex/models/phone_model.dart'; // Importe o modelo de telefone

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  children: [
                    const SideBar(),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
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
                              child: StreamBuilder<List<Phone>>( // Use StreamBuilder
                                stream: PhoneService().getPhones(), // Busque o stream de telefones
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Erro: ${snapshot.error}'));
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('Nenhum celular cadastrado.'));
                                  }

                                  final phones = snapshot.data!;
                                  return GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: phones.length, // O número de itens é o tamanho da lista de celulares
                                    itemBuilder: (context, index) {
                                      final phone = phones[index];
                                      return buildPhoneCard(
                                        phone.name,
                                        phone.imageUrl,
                                        phone.id, // Passe o ID do celular
                                        context,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 28,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const CustomBottomBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPhoneScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Celular',
      ),
    );
  }

  Widget buildPhoneCard(
      String name, String imageUrl, String phoneId, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: {
            'docId': phoneId, // Passa o ID do documento
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade300),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}