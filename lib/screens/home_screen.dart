import 'package:flutter/material.dart';
import 'package:pphonedex/components/bottombar.dart';
import 'package:pphonedex/components/sidebar.dart';
import 'package:pphonedex/components/topbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // fundo preto geral
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              children: [ 
                const SideBar(), 
                
                 
                Expanded(
                  child: Column(
                    children: [
  
                      // — Painel branco arredondado + sombra
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
                          child: Column(
                            children: [
                              // grid de cards
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: 12,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return buildPhoneCard(
                                          "IPHONE 15",
                                          'https://images.unsplash.com/photo-1696530429439-b3436906480b');
                                    } else if (index == 1) {
                                      return buildPhoneCard(
                                          "IPHONE 16",
                                          'https://images.unsplash.com/photo-1695669602536-9b0b8ae8a3d2');
                                    } else {
                                      // placeholders escuros
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),

                              // seta "ver mais"
                              const SizedBox(height: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 28,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2) BottomBar vermelha que ocupa toda a largura
          const CustomBottomBar(),
        ],
      ),
    );
  }

  /// Card de telefone com imagem + título
  Widget buildPhoneCard(String name, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // imagem no topo
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey.shade300),
              ),
            ),
          ),
          // título centralizado
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
    );
  }
}




      
  


