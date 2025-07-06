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
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      if (mounted) {
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

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
  
  if (index == 2) {
    Navigator.pushNamed(context, '/map');
  } 
  
  else if (index == 3) {
    Navigator.pushNamed(context, '/feed');
  } 
  
  else {
    setState(() {
      currentIndex = index;
    });
  }
},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.red : Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
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
                    return const Center(child: Text('Nenhum celular aprovado encontrado.'));
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
      floatingActionButton: isAdmin ? _buildAdminFab(context) : _buildUserFab(context),
      floatingActionButtonLocation: isAdmin
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.red,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(color: Colors.red),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lado esquerdo
              Row(
                children: [
                  _buildIndicatorDot(Colors.white),
                  _buildNavIcon(Icons.home, 0),
                  _buildNavIcon(Icons.favorite, 1),
                ],
              ),
              // Lado direito
              Row(
                children: [
                  _buildNavIcon(Icons.map, 2),
                  _buildNavIcon(Icons.feed, 3),
                  _buildIndicatorDot(Colors.yellow),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
