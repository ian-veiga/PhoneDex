import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<String> onSearchChanged;

  const TopBar({
    super.key,
    required this.onFilterSelected,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Estilo do container principal
      decoration: const BoxDecoration(
        color: Colors.red, // Fundo vermelho
        border: Border(
          // Borda preta, se desejar manter
          right: BorderSide(color: Colors.black, width: 2),
          top: BorderSide(color: Colors.black, width: 2),
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8, // Padding horizontal
        vertical: 12,   // Padding vertical
      ),
      child: Row(
        // Alinhamento dos itens na linha
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Botão de Menu à Esquerda (com a funcionalidade do Dropdown)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30), // Ícone branco e maior
            onSelected: onFilterSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Todos',
                child: Text('Todos'),
              ),
              const PopupMenuItem<String>(
                value: 'iOS',
                child: Text('iOS'),
              ),
              const PopupMenuItem<String>(
                value: 'Android',
                child: Text('Android'),
              ),
            ],
          ),

          const SizedBox(width: 8), // Espaçamento

          // 2. Barra de Busca Central
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.red), // Ícone de busca vermelho
              ),
            ),
          ),

          const SizedBox(width: 8), // Espaçamento

          // 3. Botão de Filtro Circular à Direita
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.red),
              onPressed: () { Navigator.pushNamed(context, '/profile');}, // Navega para a tela de perfil
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}