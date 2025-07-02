import 'package:flutter/material.dart';
import 'package:pphonedex/screens/add_phone_screen.dart';
import 'package:pphonedex/services/phone_service.dart';
import 'package:pphonedex/models/phone_model.dart';
import 'package:pphonedex/components/Phone_card.dart';
import 'package:pphonedex/components/topbar.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedOS = 'Todos';
  String searchQuery = '';
  int currentIndex = 0;

  final String userId = 'usuario_demo';

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

  void navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
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
                    return const Center(child: Text('Nenhum celular encontrado.'));
                  }

                  final phones = snapshot.data!.where((phone) {
                    final nameLower = phone.name.toLowerCase();
                    final isIOS = phone.name.toLowerCase().contains('iphone');

                    final soMatch = selectedOS == 'Todos' ||
                        (selectedOS == 'iOS' && isIOS) ||
                        (selectedOS == 'Android' && !isIOS);

                    final searchMatch = searchQuery.isEmpty || nameLower.contains(searchQuery);

                    return soMatch && searchMatch;
                  }).toList();

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: phones.length,
                    itemBuilder: (context, index) {
                      final phone = phones[index];
                      return buildPhoneCard(phone.name, phone.imageUrl, phone.id, context);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddPhoneScreen()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Celular',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
       bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.red, // Cor do BottomAppBar
        child: Container(
           width: double.infinity,
           height:double.infinity,
          decoration: const BoxDecoration(
            color: Colors.red,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: currentIndex == 0 ? Colors.white : Colors.black, // Cor ajustada para contraste
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
                  color: currentIndex == 1 ? Colors.white : Colors.black, // Cor ajustada para contraste
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 40), // Espaço para o FAB
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: currentIndex == 2 ? Colors.white : Colors.black, // Cor ajustada para contraste
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 2;
                  });
                  navigateToProfile();
                },
              ),
              // Os círculos amarelos e brancos do design original podem ser adicionados aqui se desejar
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

