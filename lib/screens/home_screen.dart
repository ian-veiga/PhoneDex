import 'package:flutter/material.dart';
import 'package:pphonedex/components/custom_bottom_bar.dart';


  class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Nova Sidebar com divisórias e botões brancos
          const SideBar(),
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.filter_list, color: Colors.white),
                    ],
                  ),
                ),
                // Grid de celulares
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: phoneList.length,
                      itemBuilder: (context, index) {
                        final phone = phoneList[index];
                        return GestureDetector(
                          onTap: () {
                            // navegar para detalhes
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(phone.imageUrl, height: 80),
                                const SizedBox(height: 8),
                                Text(
                                  phone.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Footer
                const CustomBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Colors.red,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _SidebarButton(icon: Icons.home, route: '/home'),
          const SizedBox(height: 8),
          const Divider(color: Colors.white70, thickness: 1, indent: 8, endIndent: 8),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.compare, route: '/vs'),
          const SizedBox(height: 8),
          const Divider(color: Colors.white70, thickness: 1, indent: 8, endIndent: 8),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.language, route: '/web'),
          const SizedBox(height: 8),
          const Divider(color: Colors.white70, thickness: 1, indent: 8, endIndent: 8),
          const SizedBox(height: 8),
          _SidebarButton(icon: Icons.star, route: '/favorites'),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String route;
  const _SidebarButton({required this.icon, required this.route, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.red),
      ),
    );
  }
}

class Phone {
  final String name;
  final String imageUrl;
  const Phone({required this.name, required this.imageUrl});
}

const phoneList = [
  Phone(name: 'iPhone 15', imageUrl: 'https://via.placeholder.com/80'),
  Phone(name: 'iPhone 16', imageUrl: 'https://via.placeholder.com/80'),
  // adicione mais Phones...
];

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Tela de $title ainda não implementada')),
    );
  }
}


class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String route;
  const CircleIconButton({required this.icon, required this.route, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.white,
      iconSize: 32,
      icon: Icon(icon, color: Colors.black),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}