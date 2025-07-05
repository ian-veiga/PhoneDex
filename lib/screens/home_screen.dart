import 'package:flutter/material.dart';
import 'package:pphonedex/screens/add_phone_screen.dart';
import 'package:pphonedex/services/phone_service.dart';
import 'package:pphonedex/models/phone_model.dart';
import 'package:pphonedex/components/Phone_card.dart';
import 'package:pphonedex/components/topbar.dart';
import 'package:pphonedex/screens/feed_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pphonedex/services/auth_service.dart';
import 'package:pphonedex/screens/pending_phones_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedOS = 'Todos';
  String searchQuery = '';
  int currentIndex = 0;
  String userId = 'usuario_demo';

  final AuthService _authService = AuthService();
  bool isAdmin = false; // Variável de estado local para controlar a UI

  @override
  void initState() {
    super.initState();
    // --- CORREÇÃO PRINCIPAL ---
    // A verificação de status agora é feita em uma função separada
    // para garantir que o estado seja atualizado corretamente.
    _loadUserStatus();
  }

  // Função assíncrona para carregar o status do usuário
  Future<void> _loadUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      // Acessa o valor do serviço (que foi definido no login)
      // e atualiza o estado do widget para forçar uma reconstrução da tela.
      if (mounted) { // Garante que o widget ainda está na tela
        setState(() {
          isAdmin = _authService.isAdmin;
        });
      }
    }
  }

  void handleFilterSelected(String value) {
    setState(() {
      selectedOS = value;
    });
  }

  void handleSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
  }

  // CORREÇÃO: A navegação do ícone de perfil estava errada.
  void navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  Widget _buildAdminFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PendingPhonesScreen()),
        );
      },
      backgroundColor: Colors.orangeAccent,
      tooltip: 'Aprovações Pendentes',
      child: const Icon(Icons.pending_actions, color: Colors.white),
    );
  }

  Widget _buildUserFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddPhoneScreen()));
      },
      child: const Icon(Icons.add),
      tooltip: 'Adicionar Celular',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopBar(
            onFilterSelected: (value) {
              if (value != null) {
                handleFilterSelected(value);
              }
            },
            onSearchChanged: handleSearchChanged,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: StreamBuilder<List<Phone>>(
                stream: currentIndex == 1
                    ? PhoneService().getFavoritePhones(userId)
                    : PhoneService().getPhones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Mensagem mais clara para o usuário
                    return const Center(
                        child: Text(
                            'Nenhum celular aprovado encontrado.'));
                  }

                  final phones = snapshot.data!.where((phone) {
                    final nameLower = phone.name.toLowerCase();
                    final isIOS = phone.name.toLowerCase().contains('iphone');

                    final soMatch = selectedOS == 'Todos' ||
                        (selectedOS == 'iOS' && isIOS) ||
                        (selectedOS == 'Android' && !isIOS);

                    final searchMatch =
                        searchQuery.isEmpty || nameLower.contains(searchQuery);

                    return soMatch && searchMatch;
                  }).toList();

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: phones.length,
                    itemBuilder: (context, index) {
                      final phone = phones[index];
                      return buildPhoneCard(
                          phone.name, phone.imageUrl, phone.id, context);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          isAdmin ? _buildAdminFab(context) : _buildUserFab(context),
      floatingActionButtonLocation: isAdmin
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.red,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.red,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: currentIndex == 0 ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: currentIndex == 1 ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
              ),
              if (!isAdmin) const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: currentIndex == 2 ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 2;
                  });
                  navigateToProfile();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.feed,
                  color: currentIndex == 3 ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/feed');
                },
              ),
              Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}