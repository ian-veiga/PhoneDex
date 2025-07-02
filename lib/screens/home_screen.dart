import 'package:flutter/material.dart';
import 'package:pphonedex/screens/add_phone_screen.dart';
import 'package:pphonedex/services/phone_service.dart';
import 'package:pphonedex/models/phone_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedOS = 'Todos';
  String searchQuery = '';
  int currentIndex = 0;

  final String userId = 'usuario_demo'; // 👉 Troque depois pelo UID real do Firebase Auth

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 76, 76),
        elevation: 1,
        centerTitle: true,
        title: Image.asset(
          'assets/images/nomelogo.png',
          height: 40,
        ),
      ),
      body: Column(
        children: [
          buildTopBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: StreamBuilder<List<Phone>>(
                stream: currentIndex == 1
                    ? PhoneService().getFavoritePhones(userId)  // ❤️ Aba Favoritos
                    : PhoneService().getPhones(),               // 🏠 Aba Home
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
        notchMargin: 6,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: currentIndex == 0 ? Colors.red : Colors.grey,
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
                  color: currentIndex == 1 ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: currentIndex == 2 ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 2;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Container(
     decoration: const BoxDecoration(
        color: Colors.red,
        border: Border(
          right: BorderSide(color: Colors.black, width: 2),
          top: BorderSide(color: Colors.black, width: 2),
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: selectedOS,
              onChanged: (value) {
                if (value != null) {
                  handleFilterSelected(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'iOS', child: Text('iOS')),
                DropdownMenuItem(value: 'Android', child: Text('Android')),
              ],
              isExpanded: true,
              underline: Container(),
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.black,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhoneCard(String name, String imageUrl, String phoneId, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/details', arguments: {'docId': phoneId});
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              alignment: Alignment.center,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
